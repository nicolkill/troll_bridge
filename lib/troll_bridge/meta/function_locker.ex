defmodule TrollBridge.Meta.FunctionLocker do

  alias Precuter.Args, as: PrecuterArgs
  alias Precuter.Function, as: PrecuterFunction

  defmacro __using__(_opts) do
    quote do
      @on_definition TrollBridge.Meta.FunctionLocker
    end
  end

  def __on_definition__(%Macro.Env{line: line} = env, :def, name, args, guards, _body)
      when line > 1 do
    case Module.get_last_attribute(env.module, :action) do
      nil ->
        :pass

      [{_custom_scope, action}] = tuple_action ->
        if Enum.member?(TrollBridge.allowed_actions(), action),
           do: perform_lock(tuple_action, env, name, args, guards),
           else: :pass

      action ->
        if Enum.member?(TrollBridge.allowed_actions(), action),
           do: perform_lock(action, env, name, args, guards),
           else: :pass
    end
  end

  def __on_definition__(_env, _kind, _name, _args, _guards, _body), do: :pass

  defp perform_lock(action, env, name, args, guards) do
    body = PrecuterFunction.get_body(env, name, args)
    original_func = PrecuterFunction.generate_reimplemented_func(name, args, guards, body)
    secured_func = get_secured_func(name, PrecuterArgs.purify_args(args), action)

    Module.delete_attribute(env.module, :action)
    true = Module.delete_definition(env.module, {name, length(args)})
    Module.eval_quoted(env.module, original_func)
    Module.eval_quoted(env.module, secured_func)
  end

  defp get_secured_func(name, args, action) do
    {module, conn_or_socket} =
      case args do
        [conn, _] ->
          {Phoenix.Controller, conn}

        [_, _, socket] ->
          {Phoenix.LiveView, socket}
      end

    quote do
      def unquote(name)(unquote_splicing(args)) do
        if TrollBridge.access_allowed?(unquote(conn_or_socket), unquote(action)) do
          __impl_direct_call__(unquote(name), unquote_splicing(args))
        else
          %mod{} =
            result =
              unquote(module).redirect(unquote(conn_or_socket),
                to: troll_bridge_redirect_on_failure_url()
              )

          if mod == Plug.Conn do
            result
          else
            {:ok, result}
          end
        end
      end
    end
  end
end