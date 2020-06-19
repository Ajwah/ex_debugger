defmodule Support.EdgeCases.SingleDefCases.ExpandedFormComplex.SingularArgument do
  @moduledoc false
  use ExDebugger

  def run(a) do
    %{ls: a}
    |> Map.fetch!(:ls)
    |> List.wrap
    |> Enum.reverse
    |> Enum.reduce(0, &((&1 * 2) + &2))
  end
end
