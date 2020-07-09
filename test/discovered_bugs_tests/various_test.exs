defmodule DiscoveredBugsTests.Various do
  @moduledoc false
  use ExUnit.Case, async: false

  describe "cons operator" do
    setup do
      ExDebugger.Repo.reset()

      {:ok,
       %{
         path: "test/support/discovered_bugs/cons_operator.exs"
       }}
    end

    test "usage of [... | ...] within `case` does not raise", ctx do
      Code.compile_file(ctx.path)
    end
  end

  describe "discrepancy between dd/2 and dd/3" do
    setup do
      ExDebugger.Repo.reset()

      {:ok,
       %{
         the_module: Support.DiscoveredBugs.Discrepancy_dd_2_3
       }}
    end

    test "dd/3 with true works", ctx do
      ctx.the_module.dd_3_case_2(1)
      [{_, _, dump}] = ExDebugger.Repo.dump()

      assert %{
               bindings: [input: 1],
               env: %{
                 file:
                   "/Users/kevinjohnson/projects/ex_debugger/test/support/discovered_bugs/discrepancy_dd_2_3.ex",
                 function: "&dd_3_case_2/1",
                 line: 13,
                 module: Support.DiscoveredBugs.Discrepancy_dd_2_3
               },
               label: :inspect,
               piped_value: 1
             } == dump
    end

    test "dd/3 with false works", ctx do
      ctx.the_module.dd_3_case_1(1)
      [{_, _, dump}] = ExDebugger.Repo.dump()

      assert %{
               bindings: [input: 1],
               env: %{
                 file:
                   "/Users/kevinjohnson/projects/ex_debugger/test/support/discovered_bugs/discrepancy_dd_2_3.ex",
                 function: "&dd_3_case_1/1",
                 line: 9,
                 module: Support.DiscoveredBugs.Discrepancy_dd_2_3
               },
               label: :inspect,
               piped_value: 1
             } == dump
    end

    test "dd/2 works", ctx do
      ctx.the_module.dd_2_case(1)
      [{_, _, dump}] = ExDebugger.Repo.dump()

      assert %{
               bindings: [input: 1],
               env: %{
                 file:
                   "/Users/kevinjohnson/projects/ex_debugger/test/support/discovered_bugs/discrepancy_dd_2_3.ex",
                 function: "&dd_2_case/1",
                 line: 5,
                 module: Support.DiscoveredBugs.Discrepancy_dd_2_3
               },
               label: :inspect,
               piped_value: 1
             } == dump
    end
  end
end
