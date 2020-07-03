defmodule ExDebugger.Tokenizer.Repo do
  # As explained under `ExDebugger.Tokenizer` we need to tokenize the entire file whereas the trigger is on a `def`/`defp`
  # -level. In order to ensure that we are not tokenizing the same file over and over again, this `Repo` will cache
  # accordingly.
  @moduledoc false
  @opts [:public, :named_table, :ordered_set, {:read_concurrency, true}, {:keypos, 1}]

  @doc false
  def new do
    __MODULE__
    |> :ets.info()
    |> case do
      :undefined ->
        try do
          :ets.new(__MODULE__, @opts)
        rescue
          _ -> new()
        end

      _ ->
        :already_created
    end
  end

  @doc false
  def lookup(key) do
    __MODULE__
    |> :ets.lookup(key)
    |> case do
      [] -> :not_found
      [{_, value}] -> value
    end
  end

  @doc false
  def is_uninitialized?(key) do
    __MODULE__
    |> :ets.info()
    |> case do
      :undefined ->
        new()
        :not_found

      _ ->
        lookup(key)
    end
    |> case do
      :not_found -> true
      _ -> false
    end
  end

  @doc false
  def insert(value, key) do
    __MODULE__
    |> :ets.info()
    |> case do
      :undefined -> new()
      _ -> :ok
    end

    :ets.insert(
      __MODULE__,
      {key, value}
    )
  end
end
