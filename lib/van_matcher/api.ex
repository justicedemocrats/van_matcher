defmodule VanMatcher.Api do
  use HTTPoison.Base
  import ShortMaps

  # --------------- Process request ---------------
  defp process_url(url) do
    "https://api.securevan.com/v4/#{url}"
  end

  defp process_request_headers(hdrs) do
    hdrs
    |> Enum.into(
      Accept: "application/json",
      "Content-Type": "application/json"
    )
  end

  defp process_request_options(opts) do
    api_key = Keyword.get(opts, :api_key)
    app_name = Keyword.get(opts, :app_name)
    mode = Keyword.get(opts, :mode, "van")

    mode_int =
      case mode do
        "van" -> 0
        "myc" -> 1
      end

    opts
    |> Keyword.delete(:api_key)
    |> Keyword.put(:hackney, basic_auth: {app_name, "#{api_key}|#{mode_int}"})
  end

  defp process_request_body(body) when is_map(body) do
    case Poison.encode(body) do
      {:ok, encoded} -> encoded
      {:error, _problem} -> body
    end
  end

  defp process_request_body(body) do
    body
  end

  # --------------- Process response ---------------
  defp process_response_body(text) do
    case Poison.decode(text) do
      {:ok, body} -> body
      _ -> text
    end
  end
end
