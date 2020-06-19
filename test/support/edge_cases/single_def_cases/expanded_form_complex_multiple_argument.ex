defmodule Support.EdgeCases.SingleDefCases.ExpandedFormComplex.MultipleArgument do
  @moduledoc false
  use ExDebugger

  def run(a, b, c, d) do
    %{ls: [a, b, c, d]}
    |> Map.fetch!(:ls)
    |> List.wrap
    |> Enum.reverse
    |> Enum.reduce(0, &((&1 * 2) + &2))
  end
end
