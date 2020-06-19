defmodule EdgeCases.MinimalCaseStatementTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with modules that contain `def` clauses
  encompassing simple `case` statements. The focal point of these tests
  is:
    1. Existing functionality is left unmolested
    2. `def` is augmented with a debug statement that shows the output
    of the function.
    3. Every arrow clause within a `case` statement is appended with a
    debug statement that shows the resulting output corresponding to that
    clause.
  """

  use ExUnit.Case, async: false
  alias Support.EdgeCases.CaseStatement

  @file_module_mappings %{
    CaseStatement.Minimal => "minimal",
  }

  describe "Minimal Case Statement: " do
    setup do
      ExDebugger.Repo.reset

      :ok
    end

    test ".being_piped_inside_contracted_def_form" do
      CaseStatement.Minimal
      |> run_and_assert_match(:being_piped_inside_contracted_def_form, [
        {6, "It was ok", bindings: [input: :ok]},
        {8, "It was ok", bindings: [input: :ok]}
      ])
    end

    test ".as_a_single_vanilla_statement_inside_expanded_def_form" do
      CaseStatement.Minimal
      |> run_and_assert_match(:as_a_single_vanilla_statement_inside_expanded_def_form, [
        {13, "It was error", bindings: [input: :error]},
        {14, "It was error", bindings: [input: :error]}
      ])
    end

    test ".as_a_long_single_vanilla_statement" do
      [
        [
          {19, :ok, "it was ok", bindings: [input: :ok]},
          {24, :ok, "it was ok", bindings: [input: :ok]},
        ],
        [
          {20, :error, "it was error", bindings: [input: :error]},
          {24, :error, "it was error", bindings: [input: :error]},
        ],
        [
          {21, 1, "it was 1", bindings: [input: 1]},
          {24, 1, "it was 1", bindings: [input: 1]},
        ],
        [
          {22, 2, "it was 2", bindings: [input: 2]},
          {24, 2, "it was 2", bindings: [input: 2]},
        ],
        [
          {23, 3, "it was 3", bindings: [input: 3]},
          {24, 3, "it was 3", bindings: [input: 3]},
        ],
      ]
      |> Enum.each(fn expectations ->
        run_and_assert_match(CaseStatement.Minimal, :as_a_single_vanilla_statement_inside_expanded_def_form, expectations)
        ExDebugger.Repo.reset
      end)
    end
  end

  def run_and_assert_match(module, fun, line, piped_value, bindings \\ [])
  def run_and_assert_match(module, fun, line, piped_value, bindings: bindings) do
    run_and_assert_match(module, fun, line, piped_value, bindings)
  end
  def run_and_assert_match(module, fun, expectations) do
    file_name = Map.fetch!(@file_module_mappings, module)

    expectations
    |> Enum.zip(ExDebugger.Repo.dump)
    |> Enum.each(fn {{line, piped_value, bindings}, {_, _, dump}} ->
      apply(
        module,
        fun,
        bindings
        |> Enum.reduce([], fn
          e, a when is_map(e) -> e = e
            |> Enum.reduce(%{}, fn {k, v}, a -> v
              |> case do
                {_, v} -> Map.put(a, k, v)
                vs when is_list(vs) -> Map.put(a, k, vs)
              end
            end)
            a ++ [e]

          {_, v}, a -> a ++ [v]
          e, a -> a ++ [e]
        end)
      )

      assert %{
        bindings: bindings
          |> Enum.reduce([], fn
            e, a when is_map(e) -> e = e
              |> Map.values
              |> case do
                e = [{_, _}] -> e
                e when is_list(e) -> e
              end
              a ++ e
            e = {_, v}, a when is_map(v) -> a ++ [e]
            e, a -> a ++ [e]
          end),
        env: %{
          file: "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/case_statement/#{file_name}.ex",
          function: "&#{fun}/#{Enum.count(bindings)}",
          line: line,
          module: module
        },
        label: :def_output_only,
        piped_value: piped_value
      } == dump
    end)
  end
end
