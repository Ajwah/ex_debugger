defmodule Support.EdgeCases.SingleDefCases.ExpandedFormComplex.PatternMatch do
  @moduledoc false
  use ExDebugger

  def run(%{digit: a}, %{digit: b}, %{digit: c}, %{digit: d}) do
    %{ls: [a, b, c, d]}
    |> Map.fetch!(:ls)
    |> List.wrap()
    |> Enum.reverse()
    |> Enum.reduce(0, &(&1 * 2 + &2))
  end
end
