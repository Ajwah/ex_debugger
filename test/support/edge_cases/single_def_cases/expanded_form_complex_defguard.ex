defmodule Support.EdgeCases.SingleDefCases.ExpandedFormComplex.Defguard do
  @moduledoc false
  use ExDebugger

  def run(a, b, c, d) when is_integer(a) and is_integer(b) and is_integer(c) and is_integer(d) do
    %{ls: [a, b, c, d]}
    |> Map.fetch!(:ls)
    |> List.wrap()
    |> Enum.reverse()
    |> Enum.reduce(0, &(&1 * 2 + &2))
  end
end
