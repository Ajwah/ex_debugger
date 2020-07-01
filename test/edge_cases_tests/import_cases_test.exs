defmodule EdgeCases.ImportCasesTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with modules that import other modules where one of
  the modules may opt to use ExDebugger. We need to assert the following:
    1. Ordinary functionality is maintained
    2. Debugging statements reference the module that uses ExDebugger;
    not the other module
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.ImportCases

  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  # @defp_output_label ExDebugger.Helpers.Def.default_output_labels(:defp)

  @file_module_mappings %{
    ImportCases.HelperModuleWithExDebugger => "helper_module_with_ex_debugger",
    ImportCases.HelperModuleWithoutExDebugger => "helper_module_without_ex_debugger",
    ImportCases.MainModuleWithExDebuggerImportingHelperModuleWithExDebugger =>
      "main_module_with_ex_debugger_importing_helper_module_with_ex_debugger",
    ImportCases.MainModuleWithExDebuggerImportingHelperModuleWithoutExDebugger =>
      "main_module_with_ex_debugger_importing_helper_module_without_ex_debugger",
    ImportCases.MainModuleWithoutExDebuggerImportingHelperModuleWithExDebugger =>
      "main_module_without_ex_debugger_importing_helper_module_with_ex_debugger"
  }

  setup do
    ExDebugger.Repo.reset()

    :ok
  end

  describe "MainModuleWithExDebuggerImportingHelperModuleWithExDebugger: " do
    setup do
      {
        :ok,
        %{
          module: ImportCases.MainModuleWithExDebuggerImportingHelperModuleWithExDebugger,
          helper_module: ImportCases.HelperModuleWithExDebugger
        }
      }
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls, ctx.opts], [
        {ctx.helper_module, :calculate, 3, {5, 4, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3, {6, 1, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {7, 3, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3, {8, 1.0, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {5, 5, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3, {6, 2, @def_output_label, bindings: [a: 5, b: 3]}},
        {ctx.helper_module, :calculate, 3, {7, 6, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3, {8, 2.0, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3, {5, 6, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {6, 3, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3, {7, 9, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {8, 3.0, @def_output_label, bindings: [a: 9, b: 3]}},
        {ctx.helper_module, :calculate, 3, {5, 7, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {6, 4, @def_output_label, bindings: [a: 7, b: 3]}},
        {ctx.helper_module, :calculate, 3, {7, 12, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {8, 4.0, @def_output_label, bindings: [a: 12, b: 3]}},
        {17, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: [ls: ctx.ls, opts: ctx.opts]}
      ])
    end

    @tag ls: [1, 2, 3, 4], opts: :default
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls], [
        {ctx.helper_module, :calculate, 3, {5, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3, {6, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3, {7, 1, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3, {8, 1.0, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3, {5, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3, {6, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3, {7, 2, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3, {8, 2.0, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3, {5, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3, {6, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3, {7, 3, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3, {8, 3.0, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3, {5, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3, {6, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3, {7, 4, @def_output_label, bindings: [a: 4, b: 1]}},
        {ctx.helper_module, :calculate, 3, {8, 4.0, @def_output_label, bindings: [a: 4, b: 1]}},
        {ctx.module, :run, 2,
         {17, [1.0, 2.0, 3.0, 4.0], @def_output_label,
          bindings: [ls: ctx.ls, opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]]}}
      ])
    end
  end

  describe "MainModuleWithExDebuggerImportingHelperModuleWithoutExDebugger: " do
    setup do
      {
        :ok,
        %{
          module: ImportCases.MainModuleWithExDebuggerImportingHelperModuleWithoutExDebugger,
          helper_module: ImportCases.HelperModuleWithoutExDebugger
        }
      }
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls, ctx.opts], [
        {17, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: [ls: ctx.ls, opts: ctx.opts]}
      ])
    end

    @tag ls: [1, 2, 3, 4], opts: :default
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls], [
        {ctx.module, :run, 2,
         {17, [1.0, 2.0, 3.0, 4.0], @def_output_label,
          bindings: [ls: ctx.ls, opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]]}}
      ])
    end
  end

  describe "MainModuleWithoutExDebuggerImportingHelperModuleWithExDebugger: " do
    setup do
      {
        :ok,
        %{
          module: ImportCases.MainModuleWithoutExDebuggerImportingHelperModuleWithExDebugger,
          helper_module: ImportCases.HelperModuleWithExDebugger
        }
      }
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls, ctx.opts], [
        {ctx.helper_module, :calculate, 3, {5, 4, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3, {6, 1, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {7, 3, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3, {8, 1.0, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {5, 5, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3, {6, 2, @def_output_label, bindings: [a: 5, b: 3]}},
        {ctx.helper_module, :calculate, 3, {7, 6, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3, {8, 2.0, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3, {5, 6, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {6, 3, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3, {7, 9, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3, {8, 3.0, @def_output_label, bindings: [a: 9, b: 3]}},
        {ctx.helper_module, :calculate, 3, {5, 7, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {6, 4, @def_output_label, bindings: [a: 7, b: 3]}},
        {ctx.helper_module, :calculate, 3, {7, 12, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3, {8, 4.0, @def_output_label, bindings: [a: 12, b: 3]}}
      ])
    end

    @tag ls: [1, 2, 3, 4], opts: :default
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls], [
        {ctx.helper_module, :calculate, 3, {5, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3, {6, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3, {7, 1, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3, {8, 1.0, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3, {5, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3, {6, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3, {7, 2, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3, {8, 2.0, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3, {5, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3, {6, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3, {7, 3, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3, {8, 3.0, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3, {5, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3, {6, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3, {7, 4, @def_output_label, bindings: [a: 4, b: 1]}},
        {ctx.helper_module, :calculate, 3, {8, 4.0, @def_output_label, bindings: [a: 4, b: 1]}}
      ])
    end
  end

  def run_and_assert_match(module, fun, input, expectations) do
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
            file: file(module),
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

  def file(module) do
    file_name = Map.fetch!(@file_module_mappings, module)

    "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/import_cases/#{file_name}.ex"
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
