defmodule VanMatcher.Router do
  use VanMatcher.Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(VanMatcher.SecretPlug)
  end

  scope "/", VanMatcher do
    pipe_through(:browser)
    get("/", PageController, :index)
    post("/", PageController, :queue)
  end
end
