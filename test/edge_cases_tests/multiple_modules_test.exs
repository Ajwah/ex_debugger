defmodule EdgeCases.MultipleModulesTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with multiple modules working together; be they as
  siblings to one and another or be they nested. Be they homogonous(e.g.
  they all `use ExDebugger`) or be they heterogenous.
  The focal point of these tests is:
    1. Existing functionality is left unmolested
    2. `def` is augmented with a debug statement that shows the output
    of the function.
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.MultipleModules

  @file_module_mappings %{
    MultipleModules.SingleNestedWithoutExDebugger => "single_nested_without_ex_debugger",
  }

  setup do
    ExDebugger.Repo.reset

    :ok
  end

  describe "SingleNestedWithoutExDebugger: " do
    setup do
      {:ok, %{module: MultipleModules.SingleNestedWithoutExDebugger}}
    end

    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(:run, 22, [1.0, 2.0, 3.0, 4.0], bindings: [ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]])
    end

    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, 22, [1.0, 2.0, 3.0, 4.0], bindings: [ls: [1, 2, 3, 4], opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]])
    end
  end

  def run_and_assert_match(module, fun, line, piped_value, bindings \\ [])
  def run_and_assert_match(module, fun, line, piped_value, bindings: bindings) do
    run_and_assert_match(module, fun, line, piped_value, bindings)
  end
  def run_and_assert_match(module, fun, line, piped_value, bindings) do
    apply(
      module,
      fun,
      bindings
      |> Enum.reduce([], fn
        e, a when is_map(e) -> e = e
          |> Enum.reduce(%{}, fn {k, v}, a -> v
            |> case do
              {_, v} -> Map.put(a, k, v)
              vs when is_list(vs) -> Map.put(a, k, vs)
            end
          end)
          a ++ [e]

        {_, v}, a -> a ++ [v]
        e, a -> a ++ [e]
      end)
    )
    file_name = Map.fetch!(@file_module_mappings, module)
    [{_, _, dump}] = ExDebugger.Repo.dump
      assert %{
        bindings: bindings
          |> Enum.reduce([], fn
            e, a when is_map(e) -> e = e
              |> Map.values
              |> case do
                e = [{_, _}] -> e
                e when is_list(e) -> e
              end
              a ++ e
            e = {_, v}, a when is_map(v) -> a ++ [e]
            e, a -> a ++ [e]
          end),
        env: %{
          file: "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/multiple_modules/#{file_name}.ex",
          function: "&#{fun}/#{Enum.count(bindings)}",
          line: line,
          module: module
        },
        label: :def_output_only,
        piped_value: piped_value
      } == dump
  end
end
