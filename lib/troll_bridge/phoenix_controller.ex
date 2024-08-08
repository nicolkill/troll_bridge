defmodule TrollBridge.PhoenixController do
  @moduledoc """
  Implementation for Phoenix.Controller to secure controller actions with troll_bridge
  """

  defmacro __using__(_opts) do
    quote do
      use TrollBridge.Meta.PermissionScope
      use TrollBridge.Meta.FunctionLocker

      import TrollBridge
      import TrollBridge.PhoenixController
    end
  end

end