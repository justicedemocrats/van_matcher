defmodule VanMatcher.PageController do
  use VanMatcher.Web, :controller
  import ShortMaps

  def index(conn, _params) do
    {{waiting, up_next}, _running} = Honeydew.state(:queue) |> List.first() |> Map.get(:private)

    running =
      Honeydew.status(:queue)
      |> Map.get(:workers)
      |> Map.values()
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(fn worker ->
        {task, status} = worker
        %{task: extract_task(task), status: extract_status(status)}
      end)

    queued =
      Enum.concat(
        running,
        Enum.concat(waiting, up_next)
        |> Enum.map(fn job ->
          %{task: extract_task(job), status: %{status: "waiting", progress: 0}}
        end)
      )

    render(conn, "index.html", ~m(queued)a)
  end

  def queue(conn, params = ~m(upload email api_key app_name)) do
    ~m(path filename)a = upload["file"]
    File.mkdir_p("./input-files")
    new_path = "./input-files/filename-#{DateTime.utc_now() |> DateTime.to_unix()}"
    File.rename(path, new_path)
    path = new_path

    column_mapping =
      params
      |> Enum.filter(fn {k, _v} -> String.starts_with?(k, "col_") end)
      |> Enum.map(fn {k, v} ->
        {as_int, _} = Integer.parse(v)
        {k, as_int}
      end)
      |> Enum.filter(fn {_k, v} -> v > 0 end)
      |> Enum.map(fn {k, v} -> {String.replace(k, "col_", ""), v} end)
      |> Enum.into(%{})

    Honeydew.async(
      {:process_file, [~m(column_mapping path filename email api_key app_name)]},
      :queue
    )

    redirect(conn, to: "/?secret=#{conn.assigns.secret}")
  end

  def extract_task(%{task: {_, [task]}}) do
    ~m(filename email) = task
    ~m(filename email)a
  end

  def extract_status({status, progress}) do
    status = Atom.to_string(status)
    ~m(status progress)a
  end
end
