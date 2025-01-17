defmodule EasypodcastsWeb.Router do
  use EasypodcastsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {EasypodcastsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :feed do
    plug :accepts, ["xml"]
  end

  pipeline :counter do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug EasypodcastsWeb.Api.Auth
  end

  scope "/", EasypodcastsWeb do
    pipe_through :browser
    live "/about", AboutLive.Index, :index
    live "/status", ServerLive.Index, :index
    live "/channels/:slug", ChannelLive.Show, :show
    live "/channels", ChannelLive.Index, :index
    live "/", ChannelLive.Index, :index
  end

  scope "/feeds", EasypodcastsWeb do
    pipe_through :feed
    get "/counter", ChannelController, :counter
    get "/:slug", ChannelController, :feed
  end

  scope "/api", EasypodcastsWeb do
    pipe_through :api
    get "/next", ApiController, :next
    post "/converted", ApiController, :converted
    post "/cancel", ApiController, :cancel
  end

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
      live_dashboard "/dashboard", metrics: EasypodcastsWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
