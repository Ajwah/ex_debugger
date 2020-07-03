defmodule ExDebugger.Helpers.Formatter do
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

  @doc false
  def opts, do: @opts

  @doc false
  def format(%ExDebugger.Event{} = e) do
    piped_value =
      if is_nil(e.piped_value) do
        ""
      else
        "Piped Value: #{inspect(e.piped_value, @opts)}"
      end

    """
    ===================:#{e.label}======================
    #{piped_value}
    Bindings: #{inspect(e.bindings, @opts)}

    #{format_env(e.env)}
    =============================================
    """
  end

  defp format_env(env) do
    """
    file: #{env.file}:#{env.line}
    module: #{env.module}
    function: #{inspect(env.function)}
    """
  end
end
