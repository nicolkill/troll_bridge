defmodule TrollBridgeExampleWeb.PageController do
  use TrollBridgeExampleWeb, :controller
  use TrollBridge.PhoenixController

  permissions(:page)

  redirect_on_failure_url("/api/failure")

  @action :index
  def index(conn, _params) do
    conn
    |> json(%{success: true, call: :index})
  end

  @action :show
  def show(conn, _params) do
    conn
    |> json(%{success: true, call: :show})
  end

  def failure(conn, _params) do
    conn
    |> json(%{forbidden: true})
  end

end