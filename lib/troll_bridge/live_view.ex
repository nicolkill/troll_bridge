defmodule TrollBridge.LiveView do
  @moduledoc """
  Implementation for Phoenix.LiveView to secure controller actions with troll_bridge
  """

  defmacro __using__(_opts) do
    quote do
      use TrollBridge.Meta.PermissionScope
      use TrollBridge.Meta.FunctionLocker

      import TrollBridge
      import TrollBridge.LiveView
    end
  end
end
