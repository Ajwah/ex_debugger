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

  @support_dir "#{File.cwd!()}/test/support/edge_cases/multiple_modules"
  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  @def_input_label ExDebugger.Helpers.Def.default_input_labels(:def)

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
    setup ctx do
      {:ok,
       %{
         module: MultipleModules.SingleNestedWithoutExDebugger,
         input: bindings_to_input(ctx.bindings),
         first_line: 17,
         last_line: 26
       }}
    end

    @tag def: :run,
         bindings: [
           ls: [1, 2, 3, 4],
           opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
         ]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {ctx.last_line, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag def: :run,
         bindings: [
           ls: [1, 2, 3, 4],
           opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]
         ]
    test ".run with default arguments", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, [hd(ctx.input)], [
        {ctx.module, ctx.def, 2, {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings}},
        {ctx.module, ctx.def, 2,
         {ctx.last_line, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: ctx.bindings}}
      ])
    end
  end

  describe "SingleNestedWithExDebugger: " do
    setup do
      addend_line = 8
      module = MultipleModules.SingleNestedWithExDebugger

      {:ok,
       %{
         module: module,
         helper_module: Module.concat(module, Helpers),
         def: :run,
         first_line: 19,
         last_line: 28,
         addend_line: addend_line,
         subtrahend_line: addend_line + 1,
         multiplicand_line: addend_line + 2,
         divisor_line: addend_line + 3
       }}
    end

    @tag ls: [1, 2, 3, 4], opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(:run, [ctx.ls, ctx.opts], [
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
      |> run_and_assert_match(:run, [ctx.ls], [
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

  describe "SingleNestedWithExDebuggerButDebugDisabled: " do
    setup ctx do
      {:ok,
       %{
         module: MultipleModules.SingleNestedWithExDebuggerButDebugDisabled,
         input: bindings_to_input(ctx.bindings),
         first_line: 19,
         last_line: 28,
         def: :run
       }}
    end

    @tag bindings: [
           ls: [1, 2, 3, 4],
           opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
         ]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {ctx.last_line, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [
           ls: [1, 2, 3, 4],
           opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]
         ]
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, [hd(ctx.input)], [
        {ctx.module, ctx.def, 2, {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings}},
        {ctx.module, ctx.def, 2,
         {ctx.last_line, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: ctx.bindings}}
      ])
    end
  end

  describe "SiblingsWithExDebugger: " do
    setup ctx do
      addend_line = 22
      module = MultipleModules.SiblingsWithExDebugger

      {:ok,
       %{
         module: module,
         helper_module: Module.concat(module, Helpers),
         def: :run,
         input: bindings_to_input(ctx.bindings),
         first_line: 7,
         last_line: 16,
         addend_line: addend_line,
         subtrahend_line: addend_line + 1,
         multiplicand_line: addend_line + 2,
         divisor_line: addend_line + 3
       }}
    end

    @tag bindings: [
           ls: [1, 2, 3, 4],
           opts: [addend: 3, subtrahend: 3, multiplicand: 3, divisor: 3]
         ]
    test ".run with both arguments", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
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
        {ctx.last_line, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [
           ls: [1, 2, 3, 4],
           opts: [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]
         ]
    test ".run with default argument", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, [hd(ctx.input)], [
        {ctx.module, ctx.def, 2, {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings}},
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
         {ctx.last_line, [1.0, 2.0, 3.0, 4.0], @def_output_label, bindings: ctx.bindings}}
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
