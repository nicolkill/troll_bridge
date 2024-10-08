defmodule TrollBridgeExampleWeb.Router do
  use TrollBridgeExampleWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TrollBridgeExampleWeb do
    pipe_through :api

    get "/", PageController, :index
    get "/show", PageController, :show
    get "/show_alt", PageController, :show_alt
    get "/failure", PageController, :failure
  end
end
