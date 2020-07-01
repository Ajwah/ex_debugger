defmodule ExDebugger.Repo do
  @moduledoc """
  Maintains an ETS-table in which we can cast various debugging events as
  emmited by the various annotations made when employing `use ExDebugger`
  """

  @max_counter 1_000_000
  @opts [:public, :named_table, :ordered_set, {:write_concurrency, true}, {:keypos, 1}]
  @persistent_term_key {__MODULE__, :counter_ref}
  @counter_id 1

  def new, do: new(:counters.new(@max_counter, []))

  def new(counters) do
    __MODULE__
    |> :ets.info()
    |> case do
      :undefined ->
        :ets.new(__MODULE__, @opts)
        :persistent_term.put(@persistent_term_key, counters)

      _ ->
        :already_created
    end
  end

  def dump do
    :ets.tab2list(__MODULE__)
  end

  def lookup(key) do
    __MODULE__
    |> :ets.lookup(key)
    |> case do
      [] -> :not_found
      [{_, value}] -> value
    end
  end

  def counter_ref, do: :persistent_term.get(@persistent_term_key)

  def insert(event = %ExDebugger.Event{}) do
    __MODULE__
    |> :ets.info()
    |> case do
      :undefined -> new()
      _ -> :ok
    end

    :counters.add(counter_ref(), @counter_id, 1)

    :ets.insert(
      __MODULE__,
      {:counters.get(counter_ref(), @counter_id), :erlang.system_time(:nanosecond),
       Map.from_struct(event)}
    )
  end

  def reset do
    __MODULE__
    |> :ets.info()
    |> case do
      :undefined -> new()
      _ -> :ok
    end

    :counters.put(counter_ref(), @counter_id, 0)
    :ets.delete_all_objects(__MODULE__)
  end
end
