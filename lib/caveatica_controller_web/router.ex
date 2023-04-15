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

    get "/", PageController, :home
  end

  if Application.compile_env(:caveatica_controller, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CaveaticaControllerWeb.Telemetry
    end
  end
end
