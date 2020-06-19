defmodule ExDebugger.Formatter do
  @moduledoc false
  @opts [
    limit: :infinity,
    printable_limit: :infinity,
    pretty: true,
    width: 120,
    syntax_colors: [
      atom: :light_blue,
      binary: :green,
      boolean: :light_blue,
      list: :blink_rapid,
      map: :yellow,
      number: :magenta,
      regex: :blue,
      string: :green,
      tuple: :cyan
    ]
  ]

  def opts, do: @opts

  def env_to_map(env) do
    {fun, arity} = env.function
    %{module: env.module, function: "&#{fun}/#{arity}", file: env.file, line: env.line}
  end

  def format_env(env) do
    """
    file: #{env.file}:#{env.line}
    module: #{env.module}
    function: #{inspect(env.function)}
    """
  end

  def format(nil, env, bindings, label) do
    """
    ===================:#{label}======================
    Bindings: #{inspect(bindings, @opts)}

    #{format_env(env)}
    =============================================
    """
  end

  def format(various, env, bindings, label) do
    """
    ===================:#{label}======================
    Various: #{inspect(various, @opts)}
    Bindings: #{inspect(bindings, @opts)}

    #{format_env(env)}
    =============================================
    """
  end
end
