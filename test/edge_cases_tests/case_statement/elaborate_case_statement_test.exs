defmodule EdgeCases.ElaborateCaseStatementTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with modules that contain `def` clauses
  encompassing elaborate `case` statements. The focal point of these tests
  is:
    1. Existing functionality is left unmolested
    2. `def` is augmented with a debug statement that shows the output
    of the function.
    3. Every arrow clause within a `case` statement is appended with a
    debug statement that shows the resulting output corresponding to that
    clause.
    4. Every nesting within such a case statement is properly handeled.
  """
  use ExUnit.Case, async: false
  alias Support.EdgeCases.CaseStatement

  @support_dir "#{File.cwd!()}/test/support/edge_cases/case_statement"
  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  @def_input_label ExDebugger.Helpers.Def.default_input_labels(:def)
  @case_label ExDebugger.AstWalker.default_polyfurcation_labels(:case)

  @file_module_mappings %{
    CaseStatement.Elaborate => "elaborate"
  }

  # In total 3 distinct input, each one of :ok or :error -> total of 8
  # input combinations to test
  describe ".as_several_case_statements_sequentially" do
    setup do
      ExDebugger.Repo.reset()

      {:ok,
       %{
         module: CaseStatement.Elaborate,
         def: :as_several_case_statements_sequentially,
         first_line: 5,
         last_line: 20
       }}
    end

    @tag bindings: [input1: :ok, input2: :ok, input3: :ok]
    test "Case 1", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {7, "1. It was ok", @case_label, bindings: ctx.bindings},
        {12, "2. It was ok", @case_label, bindings: ctx.bindings},
        {17, "3. It was ok", @case_label, bindings: ctx.bindings},
        {ctx.last_line, "3. It was ok", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :error, input2: :ok, input3: :ok]
    test "Case 2", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {8, "1. It was error", @case_label, bindings: ctx.bindings},
        {12, "2. It was ok", @case_label, bindings: ctx.bindings},
        {17, "3. It was ok", @case_label, bindings: ctx.bindings},
        {ctx.last_line, "3. It was ok", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :ok, input2: :error, input3: :ok]
    test "Case 3", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {7, "1. It was ok", @case_label, bindings: ctx.bindings},
        {13, "2. It was error", @case_label, bindings: ctx.bindings},
        {17, "3. It was ok", @case_label, bindings: ctx.bindings},
        {ctx.last_line, "3. It was ok", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :ok, input2: :ok, input3: :error]
    test "Case 4", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {7, "1. It was ok", @case_label, bindings: ctx.bindings},
        {12, "2. It was ok", @case_label, bindings: ctx.bindings},
        {18, "3. It was error", @case_label, bindings: ctx.bindings},
        {ctx.last_line, "3. It was error", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :error, input2: :error, input3: :ok]
    test "Case 5", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {8, "1. It was error", @case_label, bindings: ctx.bindings},
        {13, "2. It was error", @case_label, bindings: ctx.bindings},
        {17, "3. It was ok", @case_label, bindings: ctx.bindings},
        {ctx.last_line, "3. It was ok", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :error, input2: :ok, input3: :error]
    test "Case 6", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {8, "1. It was error", @case_label, bindings: ctx.bindings},
        {12, "2. It was ok", @case_label, bindings: ctx.bindings},
        {18, "3. It was error", @case_label, bindings: ctx.bindings},
        {ctx.last_line, "3. It was error", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :ok, input2: :error, input3: :error]
    test "Case 7", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {7, "1. It was ok", @case_label, bindings: ctx.bindings},
        {13, "2. It was error", @case_label, bindings: ctx.bindings},
        {18, "3. It was error", @case_label, bindings: ctx.bindings},
        {ctx.last_line, "3. It was error", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :error, input2: :error, input3: :error]
    test "Case 8", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {8, "1. It was error", @case_label, bindings: ctx.bindings},
        {13, "2. It was error", @case_label, bindings: ctx.bindings},
        {18, "3. It was error", @case_label, bindings: ctx.bindings},
        {ctx.last_line, "3. It was error", @def_output_label, bindings: ctx.bindings}
      ])
    end
  end

  # In total 3 distinct input, each one of :ok or :error -> total of 8
  # input combinations to test
  describe ".as_several_nested_case_statements" do
    setup do
      ExDebugger.Repo.reset()

      {:ok,
       %{
         module: CaseStatement.Elaborate,
         def: :as_several_nested_case_statements,
         first_line: 22,
         last_line: 54
       }}
    end

    @tag bindings: [input1: :ok, input2: :ok, input3: :ok]
    test "Case 1", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "1. It was ok"

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {28, output, @case_label, bindings: ctx.bindings},
        {31, output, @case_label, bindings: ctx.bindings},
        {38, output, @case_label, bindings: ctx.bindings},
        {ctx.last_line, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :error, input2: :ok, input3: :ok]
    test "Case 2", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "3. It was ok"

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {43, output, @case_label, bindings: ctx.bindings},
        {46, output, @case_label, bindings: ctx.bindings},
        {52, output, @case_label, bindings: ctx.bindings},
        {ctx.last_line, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :ok, input2: :error, input3: :ok]
    test "Case 3", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "2. It was ok"

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {34, output, @case_label, bindings: ctx.bindings},
        {36, output, @case_label, bindings: ctx.bindings},
        {38, output, @case_label, bindings: ctx.bindings},
        {ctx.last_line, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :ok, input2: :ok, input3: :error]
    test "Case 4", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "1. It was error"

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {29, output, @case_label, bindings: ctx.bindings},
        {31, output, @case_label, bindings: ctx.bindings},
        {38, output, @case_label, bindings: ctx.bindings},
        {ctx.last_line, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :error, input2: :error, input3: :ok]
    test "Case 5", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "4. It was ok"

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {49, output, @case_label, bindings: ctx.bindings},
        {51, output, @case_label, bindings: ctx.bindings},
        {52, output, @case_label, bindings: ctx.bindings},
        {ctx.last_line, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :error, input2: :ok, input3: :error]
    test "Case 6", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "3. It was error"

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {44, output, @case_label, bindings: ctx.bindings},
        {46, output, @case_label, bindings: ctx.bindings},
        {52, output, @case_label, bindings: ctx.bindings},
        {ctx.last_line, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :ok, input2: :error, input3: :error]
    test "Case 7", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "2. It was error"

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {35, output, @case_label, bindings: ctx.bindings},
        {36, output, @case_label, bindings: ctx.bindings},
        {38, output, @case_label, bindings: ctx.bindings},
        {ctx.last_line, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: :error, input2: :error, input3: :error]
    test "Case 8", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "4. It was error"

      ctx.module
      |> run_and_assert_match(ctx.def, input, [
        {ctx.first_line, nil, @def_input_label, bindings: ctx.bindings},
        {50, output, @case_label, bindings: ctx.bindings},
        {51, output, @case_label, bindings: ctx.bindings},
        {52, output, @case_label, bindings: ctx.bindings},
        {ctx.last_line, output, @def_output_label, bindings: ctx.bindings}
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
