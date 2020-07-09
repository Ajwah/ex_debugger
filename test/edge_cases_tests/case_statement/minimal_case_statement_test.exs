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

  @support_dir "#{File.cwd!()}/test/support/edge_cases/case_statement"
  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  @def_input_label ExDebugger.Helpers.Def.default_input_labels(:def)
  @case_label ExDebugger.AstWalker.default_polyfurcation_labels(:case)

  @file_module_mappings %{
    CaseStatement.Minimal => "minimal"
  }

  describe "Minimal Case Statement: " do
    setup ctx do
      ExDebugger.Repo.reset()

      {:ok, Map.put(ctx, :module, CaseStatement.Minimal)}
    end

    @tag input: :ok, first_line: 4, last_line: 10
    test ".being_piped_inside_contracted_def_form", ctx do
      bindings = [input: ctx.input]

      ctx.module
      |> run_and_assert_match(:being_piped_inside_contracted_def_form, ctx.input, [
        {ctx.first_line, nil, @def_input_label, bindings: bindings},
        {8, "It was ok", @case_label, bindings: bindings},
        {ctx.last_line, "It was ok", @def_output_label, bindings: bindings}
      ])
    end

    @tag input: :error, first_line: 12, last_line: 17
    test ".as_a_single_vanilla_statement_inside_expanded_def_form", ctx do
      bindings = [input: ctx.input]

      ctx.module
      |> run_and_assert_match(
        :as_a_single_vanilla_statement_inside_expanded_def_form,
        ctx.input,
        [
          {ctx.first_line, nil, @def_input_label, bindings: bindings},
          {15, "It was error", @case_label, bindings: bindings},
          {ctx.last_line, "It was error", @def_output_label, bindings: bindings}
        ]
      )
    end

    test ".as_a_long_single_vanilla_statement", ctx do
      first_line = 19
      last_line = 27

      [
        [
          {first_line, nil, @def_input_label, bindings: [input: :ok]},
          {21, "It was ok", @case_label, bindings: [input: :ok, r: :ok]},
          {last_line, "It was ok", @def_output_label, bindings: [input: :ok]}
        ],
        [
          {first_line, nil, @def_input_label, bindings: [input: :error]},
          {22, "It was error", @case_label, bindings: [input: :error, r: :error]},
          {last_line, "It was error", @def_output_label, bindings: [input: :error]}
        ],
        [
          {first_line, nil, @def_input_label, bindings: [input: 1]},
          {23, "It was 1", @case_label, bindings: [input: 1, r: 1]},
          {last_line, "It was 1", @def_output_label, bindings: [input: 1]}
        ],
        [
          {first_line, nil, @def_input_label, bindings: [input: 2]},
          {24, "It was 2", @case_label, bindings: [input: 2, r: 2]},
          {last_line, "It was 2", @def_output_label, bindings: [input: 2]}
        ],
        [
          {first_line, nil, @def_input_label, bindings: [input: 3]},
          {25, "It was 3", @case_label, bindings: [input: 3, r: 3]},
          {last_line, "It was 3", @def_output_label, bindings: [input: 3]}
        ]
      ]
      |> Enum.each(fn expectations = [{_, _, _, bindings: [{:input, input} | _]} | _] ->
        run_and_assert_match(
          ctx.module,
          :as_a_long_single_vanilla_statement,
          input,
          expectations
        )

        ExDebugger.Repo.reset()
      end)
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
