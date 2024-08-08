defmodule TrollBridge.Meta.PermissionScope do

  defmacro __using__(_opts) do
    quote do
      import TrollBridge.Meta.PermissionScope

      Module.register_attribute(__MODULE__, :troll_bridge_role, accumulate: false)
      Module.register_attribute(__MODULE__, :troll_bridge_scope, accumulate: false)
      Module.register_attribute(__MODULE__, :troll_bridge_redirect_on_failure_url, accumulate: false)
      @before_compile TrollBridge.Meta.PermissionScope
    end
  end

  defmacro __before_compile__(env) do
    role = Module.get_attribute(env.module, :troll_bridge_role)
    scope = Module.get_attribute(env.module, :troll_bridge_scope)
    redirect_on_failure_url = Module.get_attribute(env.module, :troll_bridge_redirect_on_failure_url)

    quote do
      def troll_bridge_role, do: unquote(role)
      def troll_bridge_scope, do: unquote(scope)
      def troll_bridge_redirect_on_failure_url, do: unquote(redirect_on_failure_url)
    end
  end

  defmacro role(role) do
    quote do
      @troll_bridge_role unquote(role)
    end
  end

  defmacro permissions(scope) do
    quote do
      @troll_bridge_scope unquote(scope)
    end
  end

  defmacro redirect_on_failure_url(route) do
    quote do
      @troll_bridge_redirect_on_failure_url unquote(route)
    end
  end

end