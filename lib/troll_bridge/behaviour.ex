defmodule TrollBridge.Behaviour do
  @moduledoc """
  Behaviour that works to get the needed information from the project side to work correctly the validation
  """

  @callback actions() :: [atom()]
  @callback scopes() :: [atom()]
  @callback user_roles(map()) :: [atom()]
  @callback user_permissions(map()) :: %{atom() => [atom()]}
end
