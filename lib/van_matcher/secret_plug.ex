defmodule VanMatcher.SecretPlug do
  import Plug.Conn

  def secret, do: Application.get_env(:van_matcher, :secret, "secret")

  def init(o), do: o

  def call(conn = %Plug.Conn{params: %{"secret" => input_secret}}, _) do
    if input_secret == secret() do
      conn
      |> assign(:secret, input_secret)
    else
      conn
      |> send_resp(403, "wrong secret. contact ben")
      |> halt()
    end
  end

  def call(conn, _) do
    conn
    |> send_resp(403, "missing secret")
    |> halt()
  end
end
