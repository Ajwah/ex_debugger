defmodule EdgeCases.SingleDefCasesTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with single modules that encompass a single `def`
  clause without any bifurcation occurring therein. The focal point of
  these tests is to ensure that existing functionality is maintained and
  only augmented with an extra debug expression at the end of any `def`
  within the module.
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.SingleDefCases

  @file_module_mappings %{
    SingleDefCases.ContractedFormSimple => "contracted_form_simple",
    SingleDefCases.ContractedFormComplex => "contracted_form_complex",
    SingleDefCases.ExpandedFormSimple => "expanded_form_simple",
    SingleDefCases.ExpandedFormComplex => "expanded_form_complex",
    SingleDefCases.ExpandedFormComplex.SingularArgument =>
      "expanded_form_complex_singular_argument",
    SingleDefCases.ExpandedFormComplex.MultipleArgument =>
      "expanded_form_complex_multiple_argument",
    SingleDefCases.ExpandedFormComplex.PatternMatch => "expanded_form_complex_pattern_match",
    SingleDefCases.ExpandedFormComplex.Defguard => "expanded_form_complex_defguard",
    SingleDefCases.ExpandedFormComplex.MultipleIndependentExpressions =>
      "expanded_form_complex_multiple_independent_expressions"
  }

  describe "Single Def Cases: " do
    setup do
      ExDebugger.Repo.reset()

      :ok
    end

    test "ContractedFormSimple" do
      SingleDefCases.ContractedFormSimple
      |> run_and_assert_match(6, 1)
    end

    test "ContractedFormComplex" do
      SingleDefCases.ContractedFormComplex
      |> run_and_assert_match(12, 20)
    end

    test "ExpandedFormSimple" do
      SingleDefCases.ExpandedFormSimple
      |> run_and_assert_match(7, 1)
    end

    test "ExpandedFormComplex" do
      SingleDefCases.ExpandedFormComplex
      |> run_and_assert_match(11, 20)
    end

    test "ExpandedFormComplexSingularArgument" do
      SingleDefCases.ExpandedFormComplex.SingularArgument
      |> run_and_assert_match(11, 20, bindings: [a: [1, 2, 3, 4]])
    end

    test "ExpandedFormComplexPatternMatch" do
      SingleDefCases.ExpandedFormComplex.PatternMatch
      |> run_and_assert_match(11, 20,
        bindings: [%{digit: {:a, 1}}, %{digit: {:b, 2}}, %{digit: {:c, 3}}, %{digit: {:d, 4}}]
      )
    end

    test "ExpandedFormComplexMultipleArgument" do
      SingleDefCases.ExpandedFormComplex.MultipleArgument
      |> run_and_assert_match(11, 20, bindings: [a: 1, b: 2, c: 3, d: 4])
    end

    test "ExpandedFormComplexDefguard" do
      SingleDefCases.ExpandedFormComplex.Defguard
      |> run_and_assert_match(11, 20, bindings: [a: 1, b: 2, c: 3, d: 4])
    end

    test "MultipleIndependentExpressions" do
      SingleDefCases.ExpandedFormComplex.MultipleIndependentExpressions
      |> run_and_assert_match(16, 37,
        bindings: [{:inner_binding, {:multiplied_result, 40}}, {:inner_binding, {:result, 20}}]
      )
    end
  end

  def run_and_assert_match(module, line, piped_value, bindings \\ [])

  def run_and_assert_match(module, line, piped_value, bindings: bindings) do
    run_and_assert_match(module, line, piped_value, bindings)
  end

  def run_and_assert_match(module, line, piped_value, bindings) do
    apply(
      module,
      :run,
      bindings
      |> Enum.reduce([], fn
        e, a when is_map(e) ->
          e =
            e
            |> Enum.reduce(%{}, fn {k, v}, a ->
              v
              |> case do
                {_, v} -> Map.put(a, k, v)
              end
            end)

          a ++ [e]

        {:inner_binding, _}, a ->
          a

        {_, v}, a ->
          a ++ [v]

        e, a ->
          a ++ [e]
      end)
    )

    file_name = Map.fetch!(@file_module_mappings, module)
    [{_, _, dump}] = ExDebugger.Repo.dump()

    assert %{
             bindings:
               bindings
               |> Enum.reduce([], fn
                 e, a when is_map(e) ->
                   e =
                     e
                     |> Map.values()
                     |> case do
                       e = [{_, _}] -> e
                     end

                   a ++ e

                 {:inner_binding, e}, a ->
                   a ++ [e]

                 e, a ->
                   a ++ [e]
               end),
             env: %{
               file:
                 "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/single_def_cases/#{
                   file_name
                 }.ex",
               function: format_function(bindings),
               line: line,
               module: module
             },
             label: :def_output_only,
             piped_value: piped_value
           } == dump
  end

  defp format_function(bindings) do
    arity =
      Enum.count(bindings, fn
        {k, _} -> k != :inner_binding
        _ -> true
      end)

    "&run/#{arity}"
  end
end
