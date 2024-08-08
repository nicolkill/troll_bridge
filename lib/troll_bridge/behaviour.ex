defmodule TrollBridge.Behaviour do
  @callback actions() :: [atom()]
  @callback scopes() :: [atom()]
  @callback user_roles(map()) :: [atom()]
  @callback user_permissions(map()) :: %{atom() => [atom()]}
end
