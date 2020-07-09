defmodule EdgeCases.ImportCasesTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with modules that import other modules where one of
  the modules may opt to use ExDebugger. We need to assert the following:
    1. Ordinary functionality is maintained
    2. Debugging statements reference the module that uses ExDebugger;
    not the other module

  In total there can only be four possibilities:
    1. `Module` and `Imported` both have `use ExDebugger`.
    2. `Module` `use ExDebugger` and `Imported` does not.
    3. `Module` does not `use ExDebugger` but `Imported` does.
    4. `Module` and `Imported` both do not `use ExDebugger`.

  The last possibility is irrelevant which leads us to having to test only the first three:
    1. Both produce debugging statements
    2. Only `Module` produces debugging statements
    3. Only `Imported` produces debugging statements
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.ImportCases

  @support_dir "#{File.cwd!()}/test/support/edge_cases/import_cases"
  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  @def_input_label ExDebugger.Helpers.Def.default_input_labels(:def)

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

  addend_line = 5

  @shared %{
    def: :run,
    first_line: 8,
    last_line: 17,
    addend_line: addend_line,
    subtrahend_line: addend_line + 1,
    multiplicand_line: addend_line + 2,
    divisor_line: addend_line + 3
  }

  setup do
    ExDebugger.Repo.reset()
    :ok
  end

  # 1. Both produce debugging statements
  describe "MainModuleWithExDebuggerImportingHelperModuleWithExDebugger: " do
    setup do
      {
        :ok,
        %{
          module: ImportCases.MainModuleWithExDebuggerImportingHelperModuleWithExDebugger,
          helper_module: ImportCases.HelperModuleWithExDebugger
        }
        |> Map.merge(@shared)
      }
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, [ctx.ls, ctx.opts], [
        {ctx.first_line, nil, @def_input_label, bindings: [ls: ctx.ls, opts: ctx.opts]},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 4, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 1, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 3, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 1.0, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 5, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 5, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 2, @def_output_label, bindings: [a: 5, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 6, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 2.0, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 6, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 3, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 9, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 9, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 3.0, @def_output_label, bindings: [a: 9, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 7, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 7, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 4, @def_output_label, bindings: [a: 7, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 12, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 12, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 4.0, @def_output_label, bindings: [a: 12, b: 3]}},
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
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 1, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 1.0, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 2, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 2.0, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 3, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 3.0, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 4, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 4, @def_output_label, bindings: [a: 4, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 4, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 4.0, @def_output_label, bindings: [a: 4, b: 1]}},
        {ctx.module, ctx.def, 2,
         {ctx.last_line, [1.0, 2.0, 3.0, 4.0], @def_output_label,
          bindings: [ls: ctx.ls, opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]]}}
      ])
    end
  end

  # 2. Only `Module` produces debugging statements
  describe "MainModuleWithExDebuggerImportingHelperModuleWithoutExDebugger: " do
    setup do
      {
        :ok,
        %{
          module: ImportCases.MainModuleWithExDebuggerImportingHelperModuleWithoutExDebugger,
          helper_module: ImportCases.HelperModuleWithoutExDebugger
        }
        |> Map.merge(@shared)
      }
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, [ctx.ls, ctx.opts], [
        {ctx.first_line, nil, @def_input_label, bindings: [ls: ctx.ls, opts: ctx.opts]},
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
        {ctx.module, ctx.def, 2,
         {ctx.last_line, [1.0, 2.0, 3.0, 4.0], @def_output_label,
          bindings: [ls: ctx.ls, opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]]}}
      ])
    end
  end

  # 3. Only `Imported` produces debugging statements
  describe "MainModuleWithoutExDebuggerImportingHelperModuleWithExDebugger: " do
    setup do
      {
        :ok,
        %{
          module: ImportCases.MainModuleWithoutExDebuggerImportingHelperModuleWithExDebugger,
          helper_module: ImportCases.HelperModuleWithExDebugger
        }
        |> Map.merge(@shared)
      }
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, [ctx.ls, ctx.opts], [
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 4, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 1, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 3, @def_output_label, bindings: [a: 1, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 1.0, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 5, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 5, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 2, @def_output_label, bindings: [a: 5, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 6, @def_output_label, bindings: [a: 2, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 2.0, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 6, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 3, @def_output_label, bindings: [a: 6, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 9, @def_output_label, bindings: [a: 3, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 9, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 3.0, @def_output_label, bindings: [a: 9, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 7, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 7, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 4, @def_output_label, bindings: [a: 7, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 12, @def_output_label, bindings: [a: 4, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 12, b: 3]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 4.0, @def_output_label, bindings: [a: 12, b: 3]}}
      ])
    end

    @tag ls: [1, 2, 3, 4], opts: :default
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, [ctx.ls], [
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 1, @def_output_label, bindings: [a: 1, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 1, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 1.0, @def_output_label, bindings: [a: 1, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 2, @def_output_label, bindings: [a: 2, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 2, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 2.0, @def_output_label, bindings: [a: 2, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 3, @def_output_label, bindings: [a: 3, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 3, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 3.0, @def_output_label, bindings: [a: 3, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, nil, @def_input_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.addend_line, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, nil, @def_input_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.subtrahend_line, 4, @def_output_label, bindings: [a: 4, b: 0]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, nil, @def_input_label, bindings: [a: 4, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.multiplicand_line, 4, @def_output_label, bindings: [a: 4, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, nil, @def_input_label, bindings: [a: 4, b: 1]}},
        {ctx.helper_module, :calculate, 3,
         {ctx.divisor_line, 4.0, @def_output_label, bindings: [a: 4, b: 1]}}
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

    "#{@support_dir}/#{file_name}.ex"
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
