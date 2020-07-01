defmodule ExDebugger.Event do
  @moduledoc """
  Debugging Event
  """

  defstruct [
    :piped_value,
    :label,
    :bindings,
    :env
  ]

  def new(piped_value, label, bindings, env) do
    struct(__MODULE__, %{
      piped_value: piped_value,
      label: label,
      bindings: bindings,
      env: env_to_map(env)
    })
  end

  def cast(event = %__MODULE__{}, capture_medium) do
    stdout = ExDebugger.Helpers.Formatter.format(event)

    capture_medium
    |> case do
      :stdout ->
        IO.puts(stdout)

      :repo ->
        ExDebugger.Repo.insert(event)

      :both ->
        IO.puts(stdout)
        ExDebugger.Repo.insert(event)
    end

    event.piped_value
  end

  defp env_to_map(env) do
    {fun, arity} = env.function
    %{module: env.module, function: "&#{fun}/#{arity}", file: env.file, line: env.line}
  end
end
