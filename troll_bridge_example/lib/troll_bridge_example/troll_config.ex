defmodule TrollBridgeExample.TrollConfig do
  @behaviour TrollBridge.Behaviour

  @impl TrollBridge.Behaviour
  def actions do
    [:index, :show]
  end

  @impl TrollBridge.Behaviour
  def scopes do
    [:page, :page_alt]
  end

  @impl TrollBridge.Behaviour
  def user_roles(_conn_or_socket) do
    # here use the connection to get the session user and then from user get the assigned roles
    [:user]
  end

  @impl TrollBridge.Behaviour
  def user_permissions(_conn_or_socket) do
    # here use the connection to get the session user and get the permissions of the assigned roles
    %{page: [:index]}
  end

end