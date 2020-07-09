defmodule EdgeCases.MultipleDefCasesTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with single modules that encompass multiple `def`
  clauses without any polyfurcation occurring therein. The focal point of
  these tests is that existing functionality is maintained and only
  augmented with an extra debug expression at the end of any `def`
  within the module.
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.MultipleDefCases

  @support_dir "#{File.cwd!()}/test/support/edge_cases/multiple_def_cases"

  @def_input_label ExDebugger.Helpers.Def.default_input_labels(:def)
  @defp_input_label ExDebugger.Helpers.Def.default_input_labels(:defp)

  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  @defp_output_label ExDebugger.Helpers.Def.default_output_labels(:defp)

  @file_module_mappings %{
    MultipleDefCases.Various => "various",
    MultipleDefCases.UselessSpaces => "useless_spaces",
    MultipleDefCases.Overloading => "overloading",
    MultipleDefCases.DefaultParamWithPrivateHelpers => "default_param_with_private_helpers"
  }

  setup do
    ExDebugger.Repo.reset()

    :ok
  end

  describe "Various: " do
    setup ctx do
      {:ok,
       %{
         module: MultipleDefCases.Various,
         input: binings_to_input(ctx.bindings)
       }}
    end

    @tag def: :run1, bindings: []
    test ".run1", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {5, nil, @def_input_label, bindings: ctx.bindings},
        {11, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag def: :run2,
         bindings: [%{digit: {:a, 1}}, %{digit: {:b, 2}}, %{digit: {:c, 3}}, %{digit: {:d, 4}}]
    test ".run2", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {13, nil, @def_input_label, bindings: ctx.bindings},
        {19, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag def: :run3, bindings: [a: 1, b: 2, c: 3, d: 4]
    test ".run3", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {21, nil, @def_input_label, bindings: ctx.bindings},
        {27, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag def: :run4, bindings: [a: [1, 2, 3, 4]]
    test ".run4", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {29, nil, @def_input_label, bindings: ctx.bindings},
        {35, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end
  end

  describe "UselessSpaces: " do
    setup ctx do
      {:ok,
       %{
         module: MultipleDefCases.UselessSpaces,
         input: binings_to_input(ctx.bindings)
       }}
    end

    @tag def: :run1, bindings: []
    test ".run1", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {9, nil, @def_input_label, bindings: ctx.bindings},
        {15, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag def: :run2,
         bindings: [%{digit: {:a, 1}}, %{digit: {:b, 2}}, %{digit: {:c, 3}}, %{digit: {:d, 4}}]
    test ".run2", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {17, nil, @def_input_label, bindings: ctx.bindings},
        {29, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag def: :run3, bindings: [a: 1, b: 2, c: 3, d: 4]
    test ".run3", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {45, nil, @def_input_label, bindings: ctx.bindings},
        {58, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag def: :run4, bindings: [a: [1, 2, 3, 4]]
    test ".run4", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {67, nil, @def_input_label, bindings: ctx.bindings},
        {76, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end
  end

  describe "Overloading: " do
    setup ctx do
      {:ok,
       %{
         module: MultipleDefCases.Overloading,
         input: binings_to_input(ctx.bindings)
       }}
    end

    @tag def: :run, bindings: [m: %{ls: [1, 2, 3, 4]}]
    test ".run with 1 map", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {5, nil, @def_input_label, bindings: ctx.bindings},
        {11, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag def: :run, bindings: [a: [1, 2, 3, 4]]
    test ".run with 1 list", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {13, nil, @def_input_label, bindings: ctx.bindings},
        {19, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag def: :run,
         bindings: [%{digit: {:a, 1}}, %{digit: {:b, 2}}, %{digit: {:c, 3}}, %{digit: {:d, 4}}]
    test ".run with 4 maps", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {21, nil, @def_input_label, bindings: ctx.bindings},
        {27, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag def: :run, bindings: [a: 1, b: 2, c: 3, d: 4]
    test ".run with 4 integers", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {29, nil, @def_input_label, bindings: ctx.bindings},
        {35, 20, @def_output_label, bindings: ctx.bindings}
      ])
    end
  end

  describe "DefaultParamWithPrivateHelpers: " do
    setup do
      addend_line = 21

      {:ok,
       %{
         module: MultipleDefCases.DefaultParamWithPrivateHelpers,
         def: :run,
         first_line: 10,
         last_line: 19,
         addend_line: addend_line,
         subtrahend_line: addend_line + 1,
         multiplicand_line: addend_line + 2,
         divisor_line: addend_line + 3
       }}
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, [ctx.ls, ctx.opts], [
        {ctx.first_line, nil, @def_input_label, bindings: [ls: ctx.ls, opts: ctx.opts]},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, nil, @defp_input_label, bindings: [a: 1, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, 4, @defp_output_label, bindings: [a: 1, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, nil, @defp_input_label, bindings: [a: 4, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, 1, @defp_output_label, bindings: [a: 4, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, nil, @defp_input_label, bindings: [a: 1, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, 3, @defp_output_label, bindings: [a: 1, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, nil, @defp_input_label, bindings: [a: 3, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, 1.0, @defp_output_label, bindings: [a: 3, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, nil, @defp_input_label, bindings: [a: 2, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, 5, @defp_output_label, bindings: [a: 2, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, nil, @defp_input_label, bindings: [a: 5, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, 2, @defp_output_label, bindings: [a: 5, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, nil, @defp_input_label, bindings: [a: 2, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, 6, @defp_output_label, bindings: [a: 2, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, nil, @defp_input_label, bindings: [a: 6, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, 2.0, @defp_output_label, bindings: [a: 6, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, nil, @defp_input_label, bindings: [a: 3, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, 6, @defp_output_label, bindings: [a: 3, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, nil, @defp_input_label, bindings: [a: 6, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, 3, @defp_output_label, bindings: [a: 6, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, nil, @defp_input_label, bindings: [a: 3, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, 9, @defp_output_label, bindings: [a: 3, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, nil, @defp_input_label, bindings: [a: 9, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, 3.0, @defp_output_label, bindings: [a: 9, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, nil, @defp_input_label, bindings: [a: 4, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, 7, @defp_output_label, bindings: [a: 4, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, nil, @defp_input_label, bindings: [a: 7, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, 4, @defp_output_label, bindings: [a: 7, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, nil, @defp_input_label, bindings: [a: 4, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, 12, @defp_output_label, bindings: [a: 4, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, nil, @defp_input_label, bindings: [a: 12, b: 3]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, 4.0, @defp_output_label, bindings: [a: 12, b: 3]}},
        {ctx.last_line, [1.0, 2.0, 3.0, 4.0], @def_output_label,
         bindings: [ls: ctx.ls, opts: ctx.opts]}
      ])
    end

    @tag ls: [1, 2, 3, 4], opts: :default
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, [ctx.ls], [
        {ctx.module, ctx.def, 2,
         {ctx.first_line, nil, @def_input_label,
          bindings: [ls: ctx.ls, opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, nil, @defp_input_label, bindings: [a: 1, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, 1, @defp_output_label, bindings: [a: 1, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, nil, @defp_input_label, bindings: [a: 1, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, 1, @defp_output_label, bindings: [a: 1, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, nil, @defp_input_label, bindings: [a: 1, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, 1, @defp_output_label, bindings: [a: 1, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, nil, @defp_input_label, bindings: [a: 1, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, 1.0, @defp_output_label, bindings: [a: 1, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, nil, @defp_input_label, bindings: [a: 2, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, 2, @defp_output_label, bindings: [a: 2, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, nil, @defp_input_label, bindings: [a: 2, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, 2, @defp_output_label, bindings: [a: 2, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, nil, @defp_input_label, bindings: [a: 2, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, 2, @defp_output_label, bindings: [a: 2, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, nil, @defp_input_label, bindings: [a: 2, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, 2.0, @defp_output_label, bindings: [a: 2, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, nil, @defp_input_label, bindings: [a: 3, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, 3, @defp_output_label, bindings: [a: 3, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, nil, @defp_input_label, bindings: [a: 3, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, 3, @defp_output_label, bindings: [a: 3, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, nil, @defp_input_label, bindings: [a: 3, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, 3, @defp_output_label, bindings: [a: 3, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, nil, @defp_input_label, bindings: [a: 3, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, 3.0, @defp_output_label, bindings: [a: 3, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, nil, @defp_input_label, bindings: [a: 4, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.addend_line, 4, @defp_output_label, bindings: [a: 4, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, nil, @defp_input_label, bindings: [a: 4, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.subtrahend_line, 4, @defp_output_label, bindings: [a: 4, b: 0]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, nil, @defp_input_label, bindings: [a: 4, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.multiplicand_line, 4, @defp_output_label, bindings: [a: 4, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, nil, @defp_input_label, bindings: [a: 4, b: 1]}},
        {ctx.module, :calculate, 3,
         {ctx.divisor_line, 4.0, @defp_output_label, bindings: [a: 4, b: 1]}},
        {ctx.module, ctx.def, 2,
         {ctx.last_line, [1.0, 2.0, 3.0, 4.0], @def_output_label,
          bindings: [ls: ctx.ls, opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]]}}
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

  def binings_to_input(bindings) do
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

      {_, :default}, a ->
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

      e = {_, v}, a when is_map(v) ->
        a ++ [e]

      e, a ->
        a ++ [e]
    end)
  end
end
