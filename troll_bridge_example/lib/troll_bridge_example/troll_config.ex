defmodule TrollBridgeExample.TrollConfig do
  @behaviour TrollBridge.Behaviour

  @impl TrollBridge.Behaviour
  def actions do
    [:index, :show]
  end

  @impl TrollBridge.Behaviour
  def scopes do
    [:page]
  end

  @impl TrollBridge.Behaviour
  def user_roles(_conn_or_socket) do
    [:user]
  end

  @impl TrollBridge.Behaviour
  def user_permissions(_conn_or_socket) do
    %{page: [:index]}
  end

end