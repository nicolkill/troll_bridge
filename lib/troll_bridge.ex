defmodule TrollBridge do
  @moduledoc """
  Helps to manage roles and permissions directly on controllers/live_view with just a few config to implement

  This library uses some concepts:

  - Action: basically it's just the name of the action that you want to run, a basic concept it's that  every `crud`
    function it's an action
  - Permission Scope: it's the name of system area or whatever you want to define as a group of functions that you want
    to lock with an action, a basic concept it's the controller it's an scope
  - Roles: it's the collection of scopes and actions that has the access schema of the user

  Example:

  ```
  %{
    user: %{
      page: [:index, :show]
    }
  }
  ```

  ## Usage;

  `troll_bridge` directly helps to implement to your phoenix controller or live_view screens.

  #### Add the configuration

  You need to create a module that uses the behaviour `TrollBridge.Behaviour`

  ```elixir
  # troll_bridge_example/config/config.exs
  config :troll_bridge, config: TrollBridgeExample.TrollConfig

  # troll_bridge_example/lib/troll_bridge_example/troll_config.ex
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
  ```

  #### The implementation

  - Add `use TrollBridge.PhoenixController` or `use TrollBridge.LiveView`
  - Use the `permissions` macro to define a permission scope to the entire module (optional)
  - Add the module attribute `@action :index` to your function, you can specify the permission scope

  ```elixir
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

    @action page_alt: :show
    def show_alt(conn, _params) do
      conn
      |> json(%{success: true, call: :show})
    end

    def failure(conn, _params) do
      conn
      |> json(%{forbidden: true})
    end
  end
  ```

  > The permission and the action must be defined on the scopes and actions on the implementation of  `TrollBridge.Behaviour`

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
