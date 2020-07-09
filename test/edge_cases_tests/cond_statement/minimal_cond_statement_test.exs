defmodule EdgeCases.MinimalCondStatementTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with modules that contain `def` clauses
  encompassing simple `cond` statements. The focal point of these tests
  is:
    1. Existing functionality is left unmolested
    2. `def` is augmented with a debug statement that shows the output
    of the function.
    3. Every clause within a `cond` statement is appended with a
    debug statement that shows the resulting output corresponding to that
    clause.
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.CondStatement

  @support_dir "#{File.cwd!()}/test/support/edge_cases/cond_statement"
  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  @def_input_label ExDebugger.Helpers.Def.default_input_labels(:def)
  @cond_label ExDebugger.AstWalker.default_polyfurcation_labels(:cond)

  @file_module_mappings %{
    CondStatement.Minimal => "minimal"
  }

  describe "Minimal Case Statement: " do
    setup ctx do
      ExDebugger.Repo.reset()

      {:ok,
       %{
         module: CondStatement.Minimal,
         defs: %{
           being_piped_inside_contracted_def_form: %{
             bindings: [input: ctx.input],
             first_line: 5,
             last_line: 10
           },
           as_a_single_vanilla_statement_inside_expanded_def_form: %{
             bindings: [input: ctx.input],
             first_line: 12,
             last_line: 17
           },
           as_a_single_branch: %{
             bindings: [input: ctx.input],
             first_line: 19,
             last_line: 23
           },
           with_long_branches: %{
             bindings: [input: ctx.input],
             first_line: 25,
             last_line: 41
           }
         }
       }}
    end

    @tag def: :being_piped_inside_contracted_def_form, input: true
    test ".being_piped_inside_contracted_def_form: true", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.defs[ctx.def].first_line, nil, @def_input_label,
         bindings: ctx.defs[ctx.def].bindings},
        {9, "It was ok", @cond_label, bindings: ctx.defs[ctx.def].bindings},
        {ctx.defs[ctx.def].last_line, "It was ok", @def_output_label,
         bindings: ctx.defs[ctx.def].bindings}
      ])
    end

    @tag def: :being_piped_inside_contracted_def_form, input: false
    test ".being_piped_inside_contracted_def_form: false", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.defs[ctx.def].first_line, nil, @def_input_label,
         bindings: ctx.defs[ctx.def].bindings},
        {8, "It was error", @cond_label, bindings: ctx.defs[ctx.def].bindings},
        {ctx.defs[ctx.def].last_line, "It was error", @def_output_label,
         bindings: ctx.defs[ctx.def].bindings}
      ])
    end

    @tag def: :as_a_single_vanilla_statement_inside_expanded_def_form, input: true
    test ".as_a_single_vanilla_statement_inside_expanded_def_form: true", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.defs[ctx.def].first_line, nil, @def_input_label,
         bindings: ctx.defs[ctx.def].bindings},
        {15, "It was ok", @cond_label, bindings: ctx.defs[ctx.def].bindings},
        {ctx.defs[ctx.def].last_line, "It was ok", @def_output_label,
         bindings: ctx.defs[ctx.def].bindings}
      ])
    end

    @tag def: :as_a_single_vanilla_statement_inside_expanded_def_form, input: false
    test ".as_a_single_vanilla_statement_inside_expanded_def_form: false", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.defs[ctx.def].first_line, nil, @def_input_label,
         bindings: ctx.defs[ctx.def].bindings},
        {14, "It was error", @cond_label, bindings: ctx.defs[ctx.def].bindings},
        {ctx.defs[ctx.def].last_line, "It was error", @def_output_label,
         bindings: ctx.defs[ctx.def].bindings}
      ])
    end

    @tag def: :as_a_single_branch, input: true
    test ".as_a_single_branch: true", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.defs[ctx.def].first_line, nil, @def_input_label,
         bindings: ctx.defs[ctx.def].bindings},
        {21, "It was ok", @cond_label, bindings: ctx.defs[ctx.def].bindings},
        {ctx.defs[ctx.def].last_line, "It was ok", @def_output_label,
         bindings: ctx.defs[ctx.def].bindings}
      ])
    end

    @tag def: :with_long_branches, input: true
    test ".with_long_branches: true", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.defs[ctx.def].first_line, nil, @def_input_label,
         bindings: ctx.defs[ctx.def].bindings},
        {33, 5, @cond_label, bindings: ctx.defs[ctx.def].bindings},
        {ctx.defs[ctx.def].last_line, 5, @def_output_label, bindings: ctx.defs[ctx.def].bindings}
      ])
    end

    @tag def: :with_long_branches, input: false
    test ".with_long_branches: false", ctx do
      ctx.module
      |> run_and_assert_match(ctx.def, ctx.input, [
        {ctx.defs[ctx.def].first_line, nil, @def_input_label,
         bindings: ctx.defs[ctx.def].bindings},
        {39, 10, @cond_label, bindings: ctx.defs[ctx.def].bindings},
        {ctx.defs[ctx.def].last_line, 10, @def_output_label, bindings: ctx.defs[ctx.def].bindings}
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
      |> Enum.map(fn {line, piped_value, label, bindings: bindings} ->
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
