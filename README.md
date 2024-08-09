# TrollBridge

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

- `user` is the name of the role
- `page` is the scope
- `index` and `show` are the defined actions

## Installation

If [available in Hex](https://hexdocs.pm/troll_bridge), the package can be installed
by adding `troll_bridge` to your list of dependencies in `mix.exs`:


```elixir
def deps do
  [
    {:troll_bridge, "~> 0.1.0"}
  ]
end
```

## Usage;

`troll_bridge` directly helps to implement to your phoenix controller or live_view screens.

#### Add the configuration

You need to create a module that uses the behaviour `TrollBridge.Behaviour` and add your implementation to get the right
data, like get the session user from database and load the roles and permissions from database

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
