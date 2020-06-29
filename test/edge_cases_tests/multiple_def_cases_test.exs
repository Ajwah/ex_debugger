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
    MultipleDefCases.DefaultParamWithPrivateHelpers => "default_param_with_private_helpers"
  }

  setup do
    ExDebugger.Repo.reset()

    :ok
  end

  describe "Various: " do
    setup do
      {:ok, %{module: MultipleDefCases.Various}}
    end

    test ".run1", ctx do
      ctx.module
      |> run_and_assert_match(:run1, 11, 20, bindings: [])
    end

    test ".run2", ctx do
      ctx.module
      |> run_and_assert_match(:run2, 19, 20,
        bindings: [%{digit: {:a, 1}}, %{digit: {:b, 2}}, %{digit: {:c, 3}}, %{digit: {:d, 4}}]
      )
    end

    test ".run3", ctx do
      ctx.module
      |> run_and_assert_match(:run3, 27, 20, bindings: [a: 1, b: 2, c: 3, d: 4])
    end

    test ".run4", ctx do
      ctx.module
      |> run_and_assert_match(:run4, 35, 20, bindings: [a: [1, 2, 3, 4]])
    end
  end

  describe "UselessSpaces: " do
    setup do
      {:ok, %{module: MultipleDefCases.UselessSpaces}}
    end

    test ".run1", ctx do
      ctx.module
      |> run_and_assert_match(:run1, 15, 20, bindings: [])
    end

    test ".run2", ctx do
      ctx.module
      |> run_and_assert_match(:run2, 29, 20,
        bindings: [%{digit: {:a, 1}}, %{digit: {:b, 2}}, %{digit: {:c, 3}}, %{digit: {:d, 4}}]
      )
    end

    test ".run3", ctx do
      ctx.module
      |> run_and_assert_match(:run3, 58, 20, bindings: [a: 1, b: 2, c: 3, d: 4])
    end

    test ".run4", ctx do
      ctx.module
      |> run_and_assert_match(:run4, 76, 20, bindings: [a: [1, 2, 3, 4]])
    end
  end

  describe "Overloading: " do
    setup do
      {:ok, %{module: MultipleDefCases.Overloading}}
    end

    test ".run with 1 map", ctx do
      ctx.module
      |> run_and_assert_match(:run, 11, 20, bindings: [m: %{ls: [1, 2, 3, 4]}])
    end

    test ".run with 1 list", ctx do
      ctx.module
      |> run_and_assert_match(:run, 19, 20, bindings: [a: [1, 2, 3, 4]])
    end

    test ".run with 4 maps", ctx do
      ctx.module
      |> run_and_assert_match(:run, 27, 20,
        bindings: [%{digit: {:a, 1}}, %{digit: {:b, 2}}, %{digit: {:c, 3}}, %{digit: {:d, 4}}]
      )
    end

    test ".run with 4 integers", ctx do
      ctx.module
      |> run_and_assert_match(:run, 35, 20, bindings: [a: 1, b: 2, c: 3, d: 4])
    end
  end

  describe "DefaultParamWithPrivateHelpers: " do
    setup do
      {:ok, %{module: MultipleDefCases.DefaultParamWithPrivateHelpers}}
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls, ctx.opts], [
        {ctx.module, :calculate, 3, {21, 4, :def_output_only, bindings: [a: 1, b: 3]}},
        {ctx.module, :calculate, 3, {22, 1, :def_output_only, bindings: [a: 4, b: 3]}},
        {ctx.module, :calculate, 3, {23, 3, :def_output_only, bindings: [a: 1, b: 3]}},
        {ctx.module, :calculate, 3, {24, 1.0, :def_output_only, bindings: [a: 3, b: 3]}},
        {ctx.module, :calculate, 3, {21, 5, :def_output_only, bindings: [a: 2, b: 3]}},
        {ctx.module, :calculate, 3, {22, 2, :def_output_only, bindings: [a: 5, b: 3]}},
        {ctx.module, :calculate, 3, {23, 6, :def_output_only, bindings: [a: 2, b: 3]}},
        {ctx.module, :calculate, 3, {24, 2.0, :def_output_only, bindings: [a: 6, b: 3]}},
        {ctx.module, :calculate, 3, {21, 6, :def_output_only, bindings: [a: 3, b: 3]}},
        {ctx.module, :calculate, 3, {22, 3, :def_output_only, bindings: [a: 6, b: 3]}},
        {ctx.module, :calculate, 3, {23, 9, :def_output_only, bindings: [a: 3, b: 3]}},
        {ctx.module, :calculate, 3, {24, 3.0, :def_output_only, bindings: [a: 9, b: 3]}},
        {ctx.module, :calculate, 3, {21, 7, :def_output_only, bindings: [a: 4, b: 3]}},
        {ctx.module, :calculate, 3, {22, 4, :def_output_only, bindings: [a: 7, b: 3]}},
        {ctx.module, :calculate, 3, {23, 12, :def_output_only, bindings: [a: 4, b: 3]}},
        {ctx.module, :calculate, 3, {24, 4.0, :def_output_only, bindings: [a: 12, b: 3]}},
        {19, [1.0, 2.0, 3.0, 4.0], :def_output_only, bindings: [ls: ctx.ls, opts: ctx.opts]}
      ])
    end

    @tag ls: [1, 2, 3, 4], opts: :default
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls], [
        {ctx.module, :calculate, 3, {21, 1, :def_output_only, bindings: [a: 1, b: 0]}},
        {ctx.module, :calculate, 3, {22, 1, :def_output_only, bindings: [a: 1, b: 0]}},
        {ctx.module, :calculate, 3, {23, 1, :def_output_only, bindings: [a: 1, b: 1]}},
        {ctx.module, :calculate, 3, {24, 1.0, :def_output_only, bindings: [a: 1, b: 1]}},
        {ctx.module, :calculate, 3, {21, 2, :def_output_only, bindings: [a: 2, b: 0]}},
        {ctx.module, :calculate, 3, {22, 2, :def_output_only, bindings: [a: 2, b: 0]}},
        {ctx.module, :calculate, 3, {23, 2, :def_output_only, bindings: [a: 2, b: 1]}},
        {ctx.module, :calculate, 3, {24, 2.0, :def_output_only, bindings: [a: 2, b: 1]}},
        {ctx.module, :calculate, 3, {21, 3, :def_output_only, bindings: [a: 3, b: 0]}},
        {ctx.module, :calculate, 3, {22, 3, :def_output_only, bindings: [a: 3, b: 0]}},
        {ctx.module, :calculate, 3, {23, 3, :def_output_only, bindings: [a: 3, b: 1]}},
        {ctx.module, :calculate, 3, {24, 3.0, :def_output_only, bindings: [a: 3, b: 1]}},
        {ctx.module, :calculate, 3, {21, 4, :def_output_only, bindings: [a: 4, b: 0]}},
        {ctx.module, :calculate, 3, {22, 4, :def_output_only, bindings: [a: 4, b: 0]}},
        {ctx.module, :calculate, 3, {23, 4, :def_output_only, bindings: [a: 4, b: 1]}},
        {ctx.module, :calculate, 3, {24, 4.0, :def_output_only, bindings: [a: 4, b: 1]}},
        {ctx.module, :run, 2,
         {19, [1.0, 2.0, 3.0, 4.0], :def_output_only,
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

        {_, :default}, a ->
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
                       e when is_list(e) -> e
                     end

                   a ++ e

                 e = {_, v}, a when is_map(v) ->
                   a ++ [e]

                 {k, :default}, a ->
                   a ++ [{k, apply(module, :default_arg, [])}]

                 e, a ->
                   a ++ [e]
               end),
             env: %{
               file:
                 "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/multiple_def_cases/#{
                   file_name
                 }.ex",
               function: "&#{fun}/#{Enum.count(bindings)}",
               line: line,
               module: module
             },
             label: :def_output_only,
             piped_value: piped_value
           } == dump
  end

  def run_and_assert_match(module, fun, input, expectations) do
    file_name = Map.fetch!(@file_module_mappings, module)

    file =
      "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/multiple_def_cases/#{
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
