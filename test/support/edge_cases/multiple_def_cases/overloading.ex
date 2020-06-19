defmodule Support.EdgeCases.MultipleDefCases.Overloading do
  @moduledoc false
  use ExDebugger

  def run(m = %{ls: _}), do: m
    |> Map.fetch!(:ls)
    |> List.wrap
    |> Enum.reverse
    |> Enum.reduce(0, &((&1 * 2) + &2))

  def run(a) when is_list(a) do
    %{ls: a}
    |> Map.fetch!(:ls)
    |> List.wrap
    |> Enum.reverse
    |> Enum.reduce(0, &((&1 * 2) + &2))
  end

  def run(%{digit: a}, %{digit: b}, %{digit: c}, %{digit: d}) do
    %{ls: [a, b, c, d]}
    |> Map.fetch!(:ls)
    |> List.wrap
    |> Enum.reverse
    |> Enum.reduce(0, &((&1 * 2) + &2))
  end

  def run(a, b, c, d) when is_integer(a) and is_integer(b) and is_integer(c) and is_integer(d) do
    %{ls: [a, b, c, d]}
    |> Map.fetch!(:ls)
    |> List.wrap
    |> Enum.reverse
    |> Enum.reduce(0, &((&1 * 2) + &2))
  end
end
