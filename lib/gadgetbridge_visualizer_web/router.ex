defmodule GadgetbridgeVisualizerWeb.Router do
  use GadgetbridgeVisualizerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GadgetbridgeVisualizerWeb.LayoutView, :root}

    # This is a local application, so ignore protection for now.
    #plug :protect_from_forgery

    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GadgetbridgeVisualizerWeb do
    pipe_through :browser

    # Home overview endpoint.
    get "/", PageController, :index
    get "/about", PageController, :about

    # Endpoint to update the database.
    post "/update", PageController, :update

    # Endpoint to set the date range in the session.
    post "/set_date_range", PageController, :set_date_range

    # Page to display advanced step data.
    get "/activity", ActivityController, :index
    post "/activity/set_activity_steps_grouping", ActivityController, :set_activity_steps_grouping

    get "/heart_rate", HeartController, :index
    post "/heart_rate/set_heart_rate_unit", HeartController, :set_heart_rate_unit

    get "/sleep", SleepController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", GadgetbridgeVisualizerWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GadgetbridgeVisualizerWeb.Telemetry
    end
  end
end
