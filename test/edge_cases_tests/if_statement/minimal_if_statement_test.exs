defmodule EdgeCases.MinimalIfStatementTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with modules that contain `def` clauses
  encompassing simple `if` statements. The focal point of these tests
  is:
    1. Existing functionality is left unmolested
    2. `def` is augmented with a debug statement that shows the output
    of the function.
    3. Every clause within a `if` statement is appended with a
    debug statement that shows the resulting output corresponding to that
    clause.
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.IfStatement

  @support_dir "#{File.cwd!()}/test/support/edge_cases/if_statement"
  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  @def_input_label ExDebugger.Helpers.Def.default_input_labels(:def)
  @if_label ExDebugger.AstWalker.default_polyfurcation_labels(:if)

  @file_module_mappings %{
    IfStatement.Minimal => "minimal"
  }

  describe "Minimal Case Statement: " do
    setup do
      ExDebugger.Repo.reset()

      {:ok,
       %{
         module: IfStatement.Minimal
       }}
    end

    @tag input: true, first_line: 5, last_line: 12
    test ".being_piped_inside_contracted_def_form: true", ctx do
      bindings = [input: ctx.input]

      ctx.module
      |> run_and_assert_match(:being_piped_inside_contracted_def_form, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: bindings},
        {9, "It was ok", @if_label, bindings: bindings},
        {ctx.last_line, "It was ok", @def_output_label, bindings: bindings}
      ])
    end

    @tag input: false, first_line: 5, last_line: 12
    test ".being_piped_inside_contracted_def_form: false", ctx do
      bindings = [input: ctx.input]

      ctx.module
      |> run_and_assert_match(:being_piped_inside_contracted_def_form, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: bindings},
        {11, "It was error", @if_label, bindings: bindings},
        {ctx.last_line, "It was error", @def_output_label, bindings: bindings}
      ])
    end

    @tag input: true, first_line: 14, last_line: 20
    test ".as_a_single_vanilla_statement_inside_expanded_def_form: true", ctx do
      bindings = [input: ctx.input]

      ctx.module
      |> run_and_assert_match(
        :as_a_single_vanilla_statement_inside_expanded_def_form,
        ctx.input,
        [
          {ctx.first_line, nil, @def_input_label, bindings: bindings},
          {16, "It was ok", @if_label, bindings: bindings},
          {ctx.last_line, "It was ok", @def_output_label, bindings: bindings}
        ]
      )
    end

    @tag input: false, first_line: 14, last_line: 20
    test ".as_a_single_vanilla_statement_inside_expanded_def_form: false", ctx do
      bindings = [input: ctx.input]

      ctx.module
      |> run_and_assert_match(
        :as_a_single_vanilla_statement_inside_expanded_def_form,
        ctx.input,
        [
          {ctx.first_line, nil, @def_input_label, bindings: bindings},
          {18, "It was error", @if_label, bindings: bindings},
          {ctx.last_line, "It was error", @def_output_label, bindings: bindings}
        ]
      )
    end

    @tag input: true, first_line: 22, last_line: 26
    test ".as_a_single_branch: false", ctx do
      bindings = [input: ctx.input]

      ctx.module
      |> run_and_assert_match(:as_a_single_branch, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: bindings},
        {24, "It was ok", @if_label, bindings: bindings},
        {ctx.last_line, "It was ok", @def_output_label, bindings: bindings}
      ])
    end

    @tag input: true, first_line: 28, last_line: 42
    test ".with_long_branches: true", ctx do
      bindings = [input: ctx.input]

      ctx.module
      |> run_and_assert_match(:with_long_branches, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: bindings},
        {34, 5, @if_label, bindings: bindings},
        {ctx.last_line, 5, @def_output_label, bindings: bindings}
      ])
    end

    @tag input: false, first_line: 28, last_line: 42
    test ".with_long_branches: false", ctx do
      bindings = [input: ctx.input]

      ctx.module
      |> run_and_assert_match(:with_long_branches, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: bindings},
        {40, 10, @if_label, bindings: bindings},
        {ctx.last_line, 10, @def_output_label, bindings: bindings}
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
