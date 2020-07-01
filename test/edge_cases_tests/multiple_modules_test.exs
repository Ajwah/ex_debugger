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

  In addition to the above is to demonstrate the working of `debug_options`
  when disabled for a `Helpers` module for instance
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.MultipleModules
  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  # @defp_output_label ExDebugger.Helpers.Def.default_output_labels(:defp)

  @file_module_mappings %{
    MultipleModules.SingleNestedWithoutExDebugger => "single_nested_without_ex_debugger",
    MultipleModules.SingleNestedWithExDebugger => "single_nested_with_ex_debugger",
    MultipleModules.SingleNestedWithExDebuggerButDebugDisabled =>
      "single_nested_with_ex_debugger_but_debug_disabled",
    MultipleModules.SiblingsWithExDebugger => "siblings_with_ex_debugger"
  }

  setup do
    ExDebugger.Repo.reset()

    :ok
  end

  describe "SingleNestedWithoutExDebugger: " do
    setup do
      {:ok, %{module: MultipleModules.SingleNestedWithoutExDebugger}}
    end

    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(:run, 26, [1.0, 2.0, 3.0, 4.0],
        bindings: [
          ls: [1, 2, 3, 4],
          opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
        ]
      )
    end

    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, 26, [1.0, 2.0, 3.0, 4.0],
        bindings: [
          ls: [1, 2, 3, 4],
          opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]
        ]
      )
    end
  end

  describe "SingleNestedWithExDebugger: " do
    setup do
      module = MultipleModules.SingleNestedWithExDebugger
      {:ok, %{module: module, helper_module: Module.concat(module, Helpers)}}
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls, ctx.opts], [
        {ctx.helper_module, :calculate, 3, {8, 4, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3, {9, 1, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {10, 3, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3, {11, 1.0, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {8, 5, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3, {9, 2, @def_output_label, bindings: [a: 5, b: 3]}},
        {ctx.helper_module, :calculate, 3, {10, 6, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3, {11, 2.0, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3, {8, 6, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {9, 3, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3, {10, 9, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {11, 3.0, @def_output_label, bindings: [a: 9, b: 3]}},
        {ctx.helper_module, :calculate, 3, {8, 7, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {9, 4, @def_output_label, bindings: [a: 7, b: 3]}},
        {ctx.helper_module, :calculate, 3, {10, 12, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {11, 4.0, @def_output_label, bindings: [a: 12, b: 3]}},
        {28, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: [ls: ctx.ls, opts: ctx.opts]}
      ])
    end

    @tag ls: [1, 2, 3, 4], opts: :default
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls], [
        {ctx.helper_module, :calculate, 3, {8, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3, {9, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3, {10, 1, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3, {11, 1.0, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3, {8, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3, {9, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3, {10, 2, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3, {11, 2.0, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3, {8, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3, {9, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3, {10, 3, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3, {11, 3.0, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3, {8, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3, {9, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3, {10, 4, @def_output_label, bindings: [a: 4, b: 1]}},
        {ctx.helper_module, :calculate, 3, {11, 4.0, @def_output_label, bindings: [a: 4, b: 1]}},
        {ctx.module, :run, 2,
         {28, [1.0, 2.0, 3.0, 4.0], @def_output_label,
          bindings: [ls: ctx.ls, opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]]}}
      ])
    end
  end

  describe "SingleNestedWithExDebuggerButDebugDisabled: " do
    setup do
      {:ok, %{module: MultipleModules.SingleNestedWithExDebuggerButDebugDisabled}}
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls, ctx.opts], [
        {28, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: [ls: ctx.ls, opts: ctx.opts]}
      ])
    end

    @tag ls: [1, 2, 3, 4], opts: :default
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls], [
        {ctx.module, :run, 2,
         {28, [1.0, 2.0, 3.0, 4.0], @def_output_label,
          bindings: [ls: ctx.ls, opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]]}}
      ])
    end
  end

  describe "SiblingsWithExDebugger: " do
    setup do
      module = MultipleModules.SiblingsWithExDebugger
      {:ok, %{module: module, helper_module: Module.concat(module, Helpers)}}
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls, ctx.opts], [
        {ctx.helper_module, :calculate, 3, {22, 4, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3, {23, 1, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {24, 3, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3, {25, 1.0, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {22, 5, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3, {23, 2, @def_output_label, bindings: [a: 5, b: 3]}},
        {ctx.helper_module, :calculate, 3, {24, 6, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3, {25, 2.0, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3, {22, 6, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {23, 3, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3, {24, 9, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {25, 3.0, @def_output_label, bindings: [a: 9, b: 3]}},
        {ctx.helper_module, :calculate, 3, {22, 7, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {23, 4, @def_output_label, bindings: [a: 7, b: 3]}},
        {ctx.helper_module, :calculate, 3, {24, 12, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {25, 4.0, @def_output_label, bindings: [a: 12, b: 3]}},
        {16, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: [ls: ctx.ls, opts: ctx.opts]}
      ])
    end

    @tag ls: [1, 2, 3, 4], opts: :default
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls], [
        {ctx.helper_module, :calculate, 3, {22, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3, {23, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3, {24, 1, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3, {25, 1.0, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3, {22, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3, {23, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3, {24, 2, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3, {25, 2.0, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3, {22, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3, {23, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3, {24, 3, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3, {25, 3.0, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3, {22, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3, {23, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3, {24, 4, @def_output_label, bindings: [a: 4, b: 1]}},
        {ctx.helper_module, :calculate, 3, {25, 4.0, @def_output_label, bindings: [a: 4, b: 1]}},
        {ctx.module, :run, 2,
         {16, [1.0, 2.0, 3.0, 4.0], @def_output_label,
          bindings: [ls: ctx.ls, opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]]}}
      ])
    end
  end

  def run_and_assert_match(module, fun, line, piped_value, bindings: bindings) do
    run_and_assert_match(module, fun, line, piped_value, bindings)
  end

  def run_and_assert_match(module, fun, line, piped_value, bindings) do
    apply(
      module,
      fun,
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
                       e when is_list(e) -> e
                     end

                   a ++ e

                 e = {_, v}, a when is_map(v) ->
                   a ++ [e]

                 e, a ->
                   a ++ [e]
               end),
             env: %{
               file:
                 "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/multiple_modules/#{
                   file_name
                 }.ex",
               function: "&#{fun}/#{Enum.count(bindings)}",
               line: line,
               module: module
             },
             label: @def_output_label,
             piped_value: piped_value
           } == dump
  end

  def run_and_assert_match(module, fun, input, expectations) do
    file_name = Map.fetch!(@file_module_mappings, module)

    file =
      "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/multiple_modules/#{
        file_name
      }.ex"

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
