defmodule VanMatcher.Worker do
  use Honeydew.Progress
  alias NimbleCSV.RFC4180, as: CSV
  import ShortMaps
  require Logger

  @behaviour Honeydew.Worker
  @batch_size 1

  def process_file(~m(path filename email api_key app_name column_mapping)) do
    File.mkdir_p("./files")

    without_type =
      String.split(filename, ".")
      |> Enum.reverse()
      |> Enum.slice(1..100)
      |> Enum.reverse()
      |> Enum.join(".")

    File.mkdir_p("./output-files")

    output_path = "./output-files/#{without_type}-processed.csv"
    {:ok, out} = File.open(output_path, [:write])
    header_row = ~s("VANID",) <> extract_header_line(path) <> ~s(\n)
    IO.binwrite(out, header_row)

    match_candidate_extractor = generate_match_candidate_extractor(column_mapping)

    van_opts = Enum.into(~m(api_key app_name)a, [])

    File.stream!(path)
    |> CSV.parse_stream()
    |> Stream.chunk_every(@batch_size)
    |> Stream.with_index()
    |> Stream.map(&update_progress/1)
    |> Stream.map(&process_chunk(&1, match_candidate_extractor, out, van_opts))
    |> Stream.run()

    VanMatcher.ResultsEmail.create(email, [output_path])
    |> VanMatcher.Mailer.deliver()
  end

  def update_progress({chunk, idx}) do
    progress(idx * @batch_size)
    chunk
  end

  def process_chunk(chunk, extractor, out, metadata) do
    Enum.map(chunk, fn row ->
      Task.async(fn ->
        match_body = extractor.(row)

        result =
          case VanMatcher.Api.post!(
                 "people/find",
                 match_body,
                 [],
                 Keyword.merge(metadata, timeout: 1_000_000)
               ) do
            %{status_code: 302, body: ~m(vanId)} ->
              vanId

            resp = %{status_code: 404} ->
              "Not Found"

            other ->
              "Not found"
          end

        new_row = [Enum.concat([result], row)]
        output_string = CSV.dump_to_iodata(new_row) |> IO.iodata_to_binary()
        IO.binwrite(out, output_string)
      end)
    end)
    |> Enum.each(&Task.await(&1, 1_000_000))
  end

  def extract_header_line(file) do
    {:ok, pid} = File.open(file)
    line = IO.binread(pid, :line)
    File.close(pid)
    String.trim(line)
  end

  def generate_match_candidate_extractor(mapping) do
    fn row ->
      Enum.reduce(mapping, %{}, fn {key, idx}, acc ->
        case key do
          "emailAddress" -> Map.put(acc, "emails", [%{"email" => Enum.at(row, idx - 1)}])
          "phoneNumber" -> Map.put(acc, "phones", [%{"phoneNumber" => Enum.at(row, idx - 1)}])
          _ -> Map.put(acc, key, Enum.at(row, idx - 1))
        end
      end)
      |> Enum.into(%{})
    end
  end
end
