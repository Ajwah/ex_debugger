defmodule EdgeCases.UseCasesTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with modules that `use` other modules where one of
  the modules may opt to use ExDebugger.
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.UseCases

  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)

  @file_module_mappings %{
    UseCases.HelperModuleWithExDebugger => "helper_module_with_ex_debugger",
    UseCases.HelperModuleWithExDebuggerAtModuleLevel =>
      "helper_module_with_ex_debugger_at_module_level",
    UseCases.HelperModuleWithoutExDebugger => "helper_module_without_ex_debugger",
    UseCases.MainModuleWithExDebuggerUseHelperModuleWithExDebuggerAtModuleLevel =>
      "main_module_with_ex_debugger_use_helper_module_with_ex_debugger_at_module_level",
    UseCases.MainModuleWithExDebuggerUseHelperModuleWithoutExDebugger =>
      "main_module_with_ex_debugger_use_helper_module_without_ex_debugger",
    UseCases.MainModuleWithExDebuggerUseHelperModuleWithExDebugger =>
      "main_module_with_ex_debugger_use_helper_module_with_ex_debugger",
    UseCases.MainModuleWithoutExDebuggerUseHelperModuleWithExDebugger =>
      "main_module_without_ex_debugger_use_helper_module_with_ex_debugger",
    UseCases.MainModuleWithoutExDebuggerUseHelperModuleWithExDebuggerAtModuleLevel =>
      "main_module_without_ex_debugger_use_helper_module_with_ex_debugger_at_module_level"
  }

  setup do
    ExDebugger.Repo.reset()

    :ok
  end

  @tag :not_working_properly
  describe "MainModuleWithExDebuggerUseHelperModuleWithExDebugger: " do
    setup do
      {
        :ok,
        %{
          module: UseCases.MainModuleWithExDebuggerUseHelperModuleWithExDebugger,
          helper_module: UseCases.HelperModuleWithoutExDebugger
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

    @tag ls: [1, 2, 3, 4], opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls], [
        {ctx.module, :run, 2,
         {17, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: [ls: ctx.ls, opts: ctx.opts]}}
      ])
    end
  end

  @tag :not_working_properly
  describe "MainModuleWithExDebuggerUseHelperModuleWithExDebuggerAtModuleLevel: " do
    setup do
      {
        :ok,
        %{
          module: UseCases.MainModuleWithExDebuggerUseHelperModuleWithExDebuggerAtModuleLevel,
          helper_module: UseCases.HelperModuleWithoutExDebugger
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

    @tag ls: [1, 2, 3, 4], opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls], [
        {ctx.module, :run, 2,
         {17, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: [ls: ctx.ls, opts: ctx.opts]}}
      ])
    end
  end

  @tag :not_working_properly
  describe "MainModuleWithExDebuggerUseHelperModuleWithoutExDebugger: " do
    setup do
      {
        :ok,
        %{
          module: UseCases.MainModuleWithExDebuggerUseHelperModuleWithoutExDebugger,
          helper_module: UseCases.HelperModuleWithoutExDebugger
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

    @tag ls: [1, 2, 3, 4], opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls], [
        {ctx.module, :run, 2,
         {17, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: [ls: ctx.ls, opts: ctx.opts]}}
      ])
    end
  end

  # TODO: More research required
  @tag :not_working_properly
  describe "MainModuleWithoutExDebuggerUseHelperModuleWithExDebugger: " do
    setup do
      {
        :ok,
        %{
          module: UseCases.MainModuleWithoutExDebuggerUseHelperModuleWithExDebugger,
          helper_module: UseCases.HelperModuleWithExDebugger
        }
      }
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module.run(ctx.ls, ctx.opts)

      actual =
        ExDebugger.Repo.dump()
        |> Enum.map(&elem(&1, 2))

      assert [] == actual
    end

    @tag ls: [1, 2, 3, 4], opts: :default
    test ".run with default argument", ctx do
      ctx.module.run(ctx.ls)

      actual =
        ExDebugger.Repo.dump()
        |> Enum.map(&elem(&1, 2))

      assert [] == actual
    end
  end

  # TODO: More research required
  @tag :not_working_properly
  describe "MainModuleWithoutExDebuggerUseHelperModuleWithExDebuggerAtModuleLevel: " do
    setup do
      {
        :ok,
        %{
          module: UseCases.MainModuleWithoutExDebuggerUseHelperModuleWithExDebuggerAtModuleLevel,
          helper_module: UseCases.HelperModuleWithExDebuggerAtModuleLevel
        }
      }
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module.run(ctx.ls, ctx.opts)

      actual =
        ExDebugger.Repo.dump()
        |> Enum.map(&elem(&1, 2))

      assert [] == actual
    end

    @tag ls: [1, 2, 3, 4], opts: :default
    test ".run with default argument", ctx do
      ctx.module.run(ctx.ls)

      actual =
        ExDebugger.Repo.dump()
        |> Enum.map(&elem(&1, 2))

      assert [] == actual
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

    "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/use_cases/#{file_name}.ex"
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
