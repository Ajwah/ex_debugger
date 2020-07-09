defmodule EdgeCases.SingleDefCasesTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with single modules that encompass a single `def`
  clause without any polyfurcation occurring therein. The focal point of
  these tests is to ensure that existing functionality is maintained and
  only augmented with an extra debug expression at the end of any `def`
  within the module.
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.SingleDefCases

  @support_dir "#{File.cwd!()}/test/support/edge_cases/single_def_cases"
  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  @def_input_label ExDebugger.Helpers.Def.default_input_labels(:def)

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
    setup ctx do
      ExDebugger.Repo.reset()

      {:ok, %{def: :run, input: bindings_to_input(ctx.bindings), module: ctx._module}}
    end

    @tag _module: SingleDefCases.ContractedFormSimple, first_line: 5, last_line: 6, bindings: []
    test "ContractedFormSimple", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {ctx.last_line, 1, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag _module: SingleDefCases.ContractedFormComplex, first_line: 5, last_line: 12, bindings: []
    test "ContractedFormComplex", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {ctx.last_line, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag _module: SingleDefCases.ExpandedFormSimple, first_line: 5, last_line: 7, bindings: []
    test "ExpandedFormSimple", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {ctx.last_line, 1, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag _module: SingleDefCases.ExpandedFormComplex, first_line: 5, last_line: 11, bindings: []
    test "ExpandedFormComplex", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {ctx.last_line, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag _module: SingleDefCases.ExpandedFormComplex.SingularArgument,
         first_line: 5,
         last_line: 11,
         bindings: [a: [1, 2, 3, 4]]
    test "ExpandedFormComplexSingularArgument", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {ctx.last_line, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag _module: SingleDefCases.ExpandedFormComplex.PatternMatch,
         first_line: 5,
         last_line: 11,
         bindings: [%{digit: {:a, 1}}, %{digit: {:b, 2}}, %{digit: {:c, 3}}, %{digit: {:d, 4}}]
    test "ExpandedFormComplexPatternMatch", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {ctx.last_line, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag _module: SingleDefCases.ExpandedFormComplex.MultipleArgument,
         first_line: 5,
         last_line: 11,
         bindings: [a: 1, b: 2, c: 3, d: 4]
    test "ExpandedFormComplexMultipleArgument", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {ctx.last_line, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag _module: SingleDefCases.ExpandedFormComplex.Defguard,
         first_line: 5,
         last_line: 11,
         bindings: [a: 1, b: 2, c: 3, d: 4]
    test "ExpandedFormComplexDefguard", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {ctx.last_line, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag _module: SingleDefCases.ExpandedFormComplex.MultipleIndependentExpressions,
         first_line: 5,
         last_line: 16,
         bindings: [{:inner_binding, {:multiplied_result, 40}}, {:inner_binding, {:result, 20}}]
    test "MultipleIndependentExpressions", ctx do
      SingleDefCases.ExpandedFormComplex.MultipleIndependentExpressions

      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: []},
        {ctx.last_line, 37, @def_output_label, bindings: ctx.bindings}
      ])
    end
  end

  def run_and_assert_match(module, fun, input, expectations) do
    file_name = Map.fetch!(@file_module_mappings, module)

    file = "#{@support_dir}/#{file_name}.ex"

    input = List.wrap(input)
    function = "&#{fun}/#{Enum.count(input)}"
    apply(module, fun, input)

    expected =
      expectations
      |> Enum.map(fn e ->
        {module, function, {line, piped_value, label, bindings: bindings}} =
          e
          |> case do
            {_, _, _, bindings: _} -> {module, function, e}
            {module, fun, arity, e} -> {module, "&#{fun}/#{arity}", e}
          end

        %{
          bindings: bindings(bindings),
          env: %{
            file: file,
            function: function,
            line: line,
            module: module
          },
          label: label,
          piped_value: piped_value
        }
      end)

    actual =
      ExDebugger.Repo.dump()
      |> Enum.map(&elem(&1, 2))

    assert expected == actual
  end

  def bindings_to_input(bindings) do
    bindings
    |> Enum.reduce([], fn
      e, a when is_map(e) ->
        e =
          e
          |> Enum.reduce(%{}, fn {k, v}, a ->
            v
            |> case do
              {_, v} -> Map.put(a, k, v)
              vs when is_list(vs) -> Map.put(a, k, vs)
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
  end

  def bindings(bindings) do
    bindings
    |> Enum.reduce([], fn
      e, a when is_map(e) ->
        e =
          e
          |> Map.values()
          |> case do
            e = [{_, _}] -> e
            e when is_list(e) -> e
          end

        a ++ e

      {:inner_binding, e}, a ->
        a ++ [e]

      e = {_, v}, a when is_map(v) ->
        a ++ [e]

      e, a ->
        a ++ [e]
    end)
  end
end
