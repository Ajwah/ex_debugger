defmodule Support.EdgeCases.SingleDefCases.ExpandedFormComplex.MultipleIndependentExpressions do
  @moduledoc false
  use ExDebugger
  
  def run do
    result =
      %{ls: [1, 2, 3, 4]}
      |> Map.fetch!(:ls)
      |> List.wrap
      |> Enum.reverse
      |> Enum.reduce(0, &((&1 * 2) + &2))

    multiplied_result = 2 * result

    multiplied_result - 3
  end
end
