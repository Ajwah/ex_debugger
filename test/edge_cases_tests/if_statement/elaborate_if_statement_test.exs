defmodule EdgeCases.ElaborateIfStatementTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  Here we are dealing with modules that contain `def` clauses
  encompassing elaborate `if` statements. The focal point of these tests
  is:
    1. Existing functionality is left unmolested
    2. `def` is augmented with a debug statement that shows the output
    of the function.
    3. Every clause within a `if` statement is appended with a
    debug statement that shows the resulting output corresponding to that
    clause.
    4. Every nesting within such a if statement is properly handeled.
  """
  use ExUnit.Case, async: false
  alias Support.EdgeCases.IfStatement

  @def_output_label ExDebugger.Helpers.Def.default_output_labels(:def)
  # @defp_output_label ExDebugger.Helpers.Def.default_output_labels(:defp)

  @file_module_mappings %{
    IfStatement.Elaborate => "elaborate"
  }

  # In total 3 distinct input, each one of true or false -> total of 8
  # input combinations to test
  describe ".as_several_if_statements_sequentially" do
    setup do
      ExDebugger.Repo.reset()

      {:ok, %{module: IfStatement.Elaborate}}
    end

    @tag bindings: [input1: true, input2: true, input3: true]
    test "Case 1", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(:as_several_if_statements_sequentially, input, [
        {6, "1. It was ok", :if_statement, bindings: ctx.bindings},
        {12, "2. It was ok", :if_statement, bindings: ctx.bindings},
        {18, "3. It was ok", :if_statement, bindings: ctx.bindings},
        {22, "3. It was ok", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: false, input2: true, input3: true]
    test "Case 2", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(:as_several_if_statements_sequentially, input, [
        {8, "1. It was error", :if_statement, bindings: ctx.bindings},
        {12, "2. It was ok", :if_statement, bindings: ctx.bindings},
        {18, "3. It was ok", :if_statement, bindings: ctx.bindings},
        {22, "3. It was ok", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: true, input2: false, input3: true]
    test "Case 3", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(:as_several_if_statements_sequentially, input, [
        {6, "1. It was ok", :if_statement, bindings: ctx.bindings},
        {14, "2. It was error", :if_statement, bindings: ctx.bindings},
        {18, "3. It was ok", :if_statement, bindings: ctx.bindings},
        {22, "3. It was ok", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: true, input2: true, input3: false]
    test "Case 4", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(:as_several_if_statements_sequentially, input, [
        {6, "1. It was ok", :if_statement, bindings: ctx.bindings},
        {12, "2. It was ok", :if_statement, bindings: ctx.bindings},
        {20, "3. It was error", :if_statement, bindings: ctx.bindings},
        {22, "3. It was error", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: false, input2: false, input3: true]
    test "Case 5", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(:as_several_if_statements_sequentially, input, [
        {8, "1. It was error", :if_statement, bindings: ctx.bindings},
        {14, "2. It was error", :if_statement, bindings: ctx.bindings},
        {18, "3. It was ok", :if_statement, bindings: ctx.bindings},
        {22, "3. It was ok", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: false, input2: true, input3: false]
    test "Case 6", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(:as_several_if_statements_sequentially, input, [
        {8, "1. It was error", :if_statement, bindings: ctx.bindings},
        {12, "2. It was ok", :if_statement, bindings: ctx.bindings},
        {20, "3. It was error", :if_statement, bindings: ctx.bindings},
        {22, "3. It was error", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: true, input2: false, input3: false]
    test "Case 7", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(:as_several_if_statements_sequentially, input, [
        {6, "1. It was ok", :if_statement, bindings: ctx.bindings},
        {14, "2. It was error", :if_statement, bindings: ctx.bindings},
        {20, "3. It was error", :if_statement, bindings: ctx.bindings},
        {22, "3. It was error", @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: false, input2: false, input3: false]
    test "Case 8", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))

      ctx.module
      |> run_and_assert_match(:as_several_if_statements_sequentially, input, [
        {8, "1. It was error", :if_statement, bindings: ctx.bindings},
        {14, "2. It was error", :if_statement, bindings: ctx.bindings},
        {20, "3. It was error", :if_statement, bindings: ctx.bindings},
        {22, "3. It was error", @def_output_label, bindings: ctx.bindings}
      ])
    end
  end

  # In total 3 distinct input, each one of true or false -> total of 8
  # input combinations to test
  describe ".as_several_nested_if_statements" do
    setup do
      ExDebugger.Repo.reset()

      {:ok, %{module: IfStatement.Elaborate}}
    end

    @tag bindings: [input1: true, input2: true, input3: true]
    test "Case 1", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "1. It was ok"

      ctx.module
      |> run_and_assert_match(:as_several_nested_if_statements, input, [
        {28, output, :if_statement, bindings: ctx.bindings},
        {31, output, :if_statement, bindings: ctx.bindings},
        {38, output, :if_statement, bindings: ctx.bindings},
        {54, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: false, input2: true, input3: true]
    test "Case 2", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "3. It was ok"

      ctx.module
      |> run_and_assert_match(:as_several_nested_if_statements, input, [
        {42, output, :if_statement, bindings: ctx.bindings},
        {45, output, :if_statement, bindings: ctx.bindings},
        {52, output, :if_statement, bindings: ctx.bindings},
        {54, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: true, input2: false, input3: true]
    test "Case 3", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "2. It was ok"

      ctx.module
      |> run_and_assert_match(:as_several_nested_if_statements, input, [
        {34, output, :if_statement, bindings: ctx.bindings},
        {37, output, :if_statement, bindings: ctx.bindings},
        {38, output, :if_statement, bindings: ctx.bindings},
        {54, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: true, input2: true, input3: false]
    test "Case 4", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "1. It was error"

      ctx.module
      |> run_and_assert_match(:as_several_nested_if_statements, input, [
        {30, output, :if_statement, bindings: ctx.bindings},
        {31, output, :if_statement, bindings: ctx.bindings},
        {38, output, :if_statement, bindings: ctx.bindings},
        {54, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: false, input2: false, input3: true]
    test "Case 5", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "4. It was ok"

      ctx.module
      |> run_and_assert_match(:as_several_nested_if_statements, input, [
        {48, output, :if_statement, bindings: ctx.bindings},
        {51, output, :if_statement, bindings: ctx.bindings},
        {52, output, :if_statement, bindings: ctx.bindings},
        {54, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: false, input2: true, input3: false]
    test "Case 6", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "3. It was error"

      ctx.module
      |> run_and_assert_match(:as_several_nested_if_statements, input, [
        {44, output, :if_statement, bindings: ctx.bindings},
        {45, output, :if_statement, bindings: ctx.bindings},
        {52, output, :if_statement, bindings: ctx.bindings},
        {54, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: true, input2: false, input3: false]
    test "Case 7", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "2. It was error"

      ctx.module
      |> run_and_assert_match(:as_several_nested_if_statements, input, [
        {36, output, :if_statement, bindings: ctx.bindings},
        {37, output, :if_statement, bindings: ctx.bindings},
        {38, output, :if_statement, bindings: ctx.bindings},
        {54, output, @def_output_label, bindings: ctx.bindings}
      ])
    end

    @tag bindings: [input1: false, input2: false, input3: false]
    test "Case 8", ctx do
      input = Enum.map(ctx.bindings, &elem(&1, 1))
      output = "4. It was error"

      ctx.module
      |> run_and_assert_match(:as_several_nested_if_statements, input, [
        {50, output, :if_statement, bindings: ctx.bindings},
        {51, output, :if_statement, bindings: ctx.bindings},
        {52, output, :if_statement, bindings: ctx.bindings},
        {54, output, @def_output_label, bindings: ctx.bindings}
      ])
    end
  end

  def run_and_assert_match(module, fun, input, expectations) do
    file_name = Map.fetch!(@file_module_mappings, module)

    file =
      "/Users/kevinjohnson/projects/ex_debugger/test/support/edge_cases/if_statement/#{file_name}.ex"

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
