defmodule ExDebugger.Event do
  @moduledoc false

  defstruct [
    :piped_value,
    :label,
    :bindings,
    :env
  ]

  require Logger

  @doc false
  def new(piped_value, label, bindings, env) do
    struct(__MODULE__, %{
      piped_value: piped_value,
      label: label,
      bindings: bindings,
      env: env_to_map(env)
    })
  end

  @doc false
  def cast(event = %__MODULE__{}, capture_medium, warn: warn?) do
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

      :none ->
        if warn? do
          Logger.warn("Capture Medium Set To None.")
        end
    end

    event.piped_value
  end

  @doc false
  defp env_to_map(env) do
    {fun, arity} = env.function
    %{module: env.module, function: "&#{fun}/#{arity}", file: env.file, line: env.line}
  end
end
