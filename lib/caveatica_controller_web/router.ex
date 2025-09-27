defmodule CaveaticaControllerWeb.Router do
  use CaveaticaControllerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CaveaticaControllerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", CaveaticaControllerWeb do
    pipe_through :browser

    live "/", HomeLive.Index, :index
    get "/health", PageController, :health
  end
end
