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

  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  # @defp_output_label ExDebugger.Helpers.Def.default_output_labels(:defp)

  @file_module_mappings %{
    CondStatement.Minimal => "minimal"
  }

  describe "Minimal Case Statement: " do
    setup do
      ExDebugger.Repo.reset()

      {:ok,
       %{
         module: CondStatement.Minimal
       }}
    end

    test ".being_piped_inside_contracted_def_form: :ok", ctx do
      ctx.module
      |> run_and_assert_match(:being_piped_inside_contracted_def_form, true, [
        {9, "It was ok", :cond_statement, bindings: [input: true]},
        {10, "It was ok", @def_output_label, bindings: [input: true]}
      ])
    end

    test ".being_piped_inside_contracted_def_form: :error", ctx do
      ctx.module
      |> run_and_assert_match(:being_piped_inside_contracted_def_form, false, [
        {8, "It was error", :cond_statement, bindings: [input: false]},
        {10, "It was error", @def_output_label, bindings: [input: false]}
      ])
    end

    test ".as_a_single_vanilla_statement_inside_expanded_def_form: true", ctx do
      ctx.module
      |> run_and_assert_match(:as_a_single_vanilla_statement_inside_expanded_def_form, true, [
        {15, "It was ok", :cond_statement, bindings: [input: true]},
        {17, "It was ok", @def_output_label, bindings: [input: true]}
      ])
    end

    test ".as_a_single_vanilla_statement_inside_expanded_def_form: false", ctx do
      ctx.module
      |> run_and_assert_match(:as_a_single_vanilla_statement_inside_expanded_def_form, false, [
        {14, "It was error", :cond_statement, bindings: [input: false]},
        {17, "It was error", @def_output_label, bindings: [input: false]}
      ])
    end

    test ".as_a_single_branch: false", ctx do
      ctx.module
      |> run_and_assert_match(:as_a_single_branch, true, [
        {21, "It was ok", :cond_statement, bindings: [input: true]},
        {23, "It was ok", @def_output_label, bindings: [input: true]}
      ])
    end

    test ".with_long_branches: true", ctx do
      ctx.module
      |> run_and_assert_match(:with_long_branches, true, [
        {33, 5, :cond_statement, bindings: [input: true]},
        {41, 5, @def_output_label, bindings: [input: true]}
      ])
    end

    test ".with_long_branches: false", ctx do
      ctx.module
      |> run_and_assert_match(:with_long_branches, false, [
        {39, 10, :cond_statement, bindings: [input: false]},
        {41, 10, @def_output_label, bindings: [input: false]}
      ])
    end
  end

  def run_and_assert_match(module, fun, input, expectations) do
    file_name = Map.fetch!(@file_module_mappings, module)

    file =
      "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/cond_statement/#{
        file_name
      }.ex"

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
