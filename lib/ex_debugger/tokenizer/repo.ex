defmodule ExDebugger.Tokenizer.Repo do
  @moduledoc false
  @opts [:public, :named_table, :ordered_set, {:read_concurrency, true}, {:keypos, 1}]

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

  def lookup(key) do
    __MODULE__
    |> :ets.lookup(key)
    |> case do
      [] -> :not_found
      [{_, value}] -> value
    end
  end

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
