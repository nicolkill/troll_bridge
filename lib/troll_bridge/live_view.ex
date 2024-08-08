defmodule TrollBridge.LiveView do
  defmacro __using__(_opts) do
    quote do
      use TrollBridge.Meta.PermissionScope
      use TrollBridge.Meta.FunctionLocker

      import TrollBridge
      import TrollBridge.LiveView
    end
  end
end
