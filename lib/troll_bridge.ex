defmodule TrollBridge do
  @moduledoc """
  Documentation for `TrollBridge`.
  """

  @type role_permissions() :: %{
                                atom() => [atom()]
                              }

  @type allowed_actions :: [atom()]
  def allowed_actions, do: get_config().actions()

  @type allowed_actions_string :: [String.t()]
  def allowed_actions_string, do: allowed_actions() |> Enum.map(&to_string/1)

  @spec allowed?(role_permissions(), atom(), atom()) :: boolean()
  def allowed?(permissions, scope, action) do
    if Enum.member?(allowed_actions(), action) do
      permissions
      |> Map.get(scope, [])
      |> then(fn actions ->
        Enum.member?(actions, :all) or Enum.member?(actions, action)
      end)
    else
      false
    end
  end

  def access_allowed?(conn_or_socket, [{scope_or_role, action}]) do
    cond do
      Enum.member?(get_config().scopes(), scope_or_role) ->
        conn_or_socket
        |> get_config().user_permissions()
        |> allowed?(scope_or_role, action)

      true ->
        conn_or_socket
        |> get_config().user_roles()
        |> Enum.member?(scope_or_role)
    end
  end

  def access_allowed?(conn_or_socket, action) do
    case scope(conn_or_socket) do
      nil ->
        role = role(conn_or_socket)
        conn_or_socket
        |> get_config().user_roles()
        |> Enum.member?(role)

      scope ->
        conn_or_socket
        |> get_config().user_permissions()
        |> allowed?(scope, action)
    end
  end

  defp scope(conn_or_socket) do
    conn_or_socket
    |> get_module()
    |> then(& &1.troll_bridge_scope())
  end

  defp role(conn_or_socket) do
    conn_or_socket
    |> get_module()
    |> then(& &1.troll_bridge_role())
  end

  defp get_module(%{private: private}),
       do: Map.get(private, :phoenix_controller)

  defp get_module(%{view: view}),
       do: view

  def get_config, do: Application.get_env(:troll_bridge, :config)
end
