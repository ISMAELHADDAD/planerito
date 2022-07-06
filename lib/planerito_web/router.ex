defmodule PlaneritoWeb.Router do
  use PlaneritoWeb, :router

  import Plug.BasicAuth

  pipeline :browser do
    plug :basic_auth, username: "test", password: "test"
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PlaneritoWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", PlaneritoWeb do
    pipe_through :browser

    live "/", WeekViewLive.Index, :index
  end

  # Live Dashboard (only on dev)

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PlaneritoWeb.Telemetry
    end
  end
end
