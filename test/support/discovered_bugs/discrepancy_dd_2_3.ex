defmodule Support.DiscoveredBugs.Discrepancy_dd_2_3 do
  use ExDebugger.Manual

  def dd_2_case(input) do
    input |> dd(:inspect)
  end

  def dd_3_case_1(input) do
    input |> dd(:inspect, false)
  end

  def dd_3_case_2(input) do
    input |> dd(:inspect, true)
  end
end
