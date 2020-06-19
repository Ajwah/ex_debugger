defmodule Support.EdgeCases.SingleDefCases.ContractedFormComplex do
  @moduledoc false
  use ExDebugger

  def run, do: %{ls: [1, 2, 3, 4]}
    |> Map.fetch!(:ls)
    |> List.wrap
    |> Enum.reverse
    |> Enum.reduce(0, &((&1 * 2) + &2))
end
