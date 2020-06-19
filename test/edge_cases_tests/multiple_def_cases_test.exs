defmodule EdgeCases.MultipleDefCasesTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with single modules that encompass multiple `def`
  clauses without any bifurcation occurring therein. The focal point of
  these tests is that existing functionality is maintained and only
  augmented with an extra debug expression at the end of any `def`
  within the module.
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.MultipleDefCases

  @file_module_mappings %{
    MultipleDefCases.Various => "various",
    MultipleDefCases.UselessSpaces => "useless_spaces",
    MultipleDefCases.Overloading => "overloading",
    MultipleDefCases.DefaultParamWithPrivateHelpers => "default_param_with_private_helpers",
  }

  setup do
    ExDebugger.Repo.reset

    :ok
  end

  describe "Various: " do
    setup do
      {:ok, %{module: MultipleDefCases.Various}}
    end

    test ".run1", ctx do
      ctx.module
      |> run_and_assert_match(:run1, 9, 20)
    end

    test ".run2", ctx do
      ctx.module
      |> run_and_assert_match(:run2, 16, 20, bindings: [%{digit: {:a, 1}}, %{digit: {:b, 2}}, %{digit: {:c, 3}}, %{digit: {:d, 4}}])
    end

    test ".run3", ctx do
      ctx.module
      |> run_and_assert_match(:run3, 24, 20, bindings: [a: 1, b: 2, c: 3, d: 4])
    end

    test ".run4", ctx do
      ctx.module
      |> run_and_assert_match(:run4, 32, 20, bindings: [a: [1, 2, 3, 4]])
    end
  end

  describe "UselessSpaces: " do
    setup do
      {:ok, %{module: MultipleDefCases.UselessSpaces}}
    end

    test ".run1", ctx do
      ctx.module
      |> run_and_assert_match(:run1, 15, 20)
    end

    test ".run2", ctx do
      ctx.module
      |> run_and_assert_match(:run2, 28, 20, bindings: [%{digit: {:a, 1}}, %{digit: {:b, 2}}, %{digit: {:c, 3}}, %{digit: {:d, 4}}])
    end

    test ".run3", ctx do
      ctx.module
      |> run_and_assert_match(:run3, 57, 20, bindings: [a: 1, b: 2, c: 3, d: 4])
    end

    test ".run4", ctx do
      ctx.module
      |> run_and_assert_match(:run4, 75, 20, bindings: [a: [1, 2, 3, 4]])
    end
  end

  describe "Overloading: " do
    setup do
      {:ok, %{module: MultipleDefCases.Overloading}}
    end

    test ".run with 1 map", ctx do
      ctx.module
      |> run_and_assert_match(:run, 9, 20, bindings: [m: %{ls: [1, 2, 3, 4]}])
    end

    test ".run with 1 list", ctx do
      ctx.module
      |> run_and_assert_match(:run, 16, 20, bindings: [a: [1, 2, 3, 4]])
    end

    test ".run with 4 maps", ctx do
      ctx.module
      |> run_and_assert_match(:run, 24, 20, bindings: [%{digit: {:a, 1}}, %{digit: {:b, 2}}, %{digit: {:c, 3}}, %{digit: {:d, 4}}])
    end

    test ".run with 4 integers", ctx do
      ctx.module
      |> run_and_assert_match(:run, 32, 20, bindings: [a: 1, b: 2, c: 3, d: 4])
    end
  end

  describe "DefaultParamWithPrivateHelpers: " do
    setup do
      {:ok, %{module: MultipleDefCases.DefaultParamWithPrivateHelpers}}
    end

    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(:run, 15, [1.0, 2.0, 3.0, 4.0], bindings: [ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]])
    end

    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, 15, [1.0, 2.0, 3.0, 4.0], bindings: [ls: [1, 2, 3, 4], opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]])
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
          file: "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/multiple_def_cases/#{file_name}.ex",
          function: "&#{fun}/#{Enum.count(bindings)}",
          line: line,
          module: module
        },
        label: :def_output_only,
        piped_value: piped_value
      } == dump
  end
end
