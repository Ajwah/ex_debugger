defmodule ExDebuggerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  # test "macro has certain output in certain format" do
  #   """
  #   ===================:test======================
  #   Various: "This is a test"
  #   Bindings: [a: 1]

  #   file: /Users/kevinjohnson/projects/ex_debugger/test/support/a.ex:6
  #   module: Elixir.A
  #   function: {:t, 1}

  #   =============================================

  #   """
  #   |> assert_capture_io(fn -> A.t(1) end)
  # end

  # test "test" do
  #   B.test(%{a: 1}, %{b: 2}, 3) |> IO.inspect
  # end

  describe "Handles Case Statements:" do
    setup do
      ExDebugger.Repo.reset

      :ok
    end

    # test "minimal case: :ok" do
    #   expected = [
    #     %{
    #       bindings: [input: :ok],
    #       line: 5,
    #       piped_value: nil,
    #       label: :def_input
    #     },
    #     %{
    #       bindings: [input: :ok],
    #       line: 7,
    #       piped_value: "It was ok",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input: :ok],
    #       line: 9,
    #       piped_value: "It was ok",
    #       label: :def_output
    #     },
    #   ]
    #   Support.CaseStatement.Minimal.as_a_single_vanilla_statement(:ok)

    #   assert_events_match_repo(expected)
    # end

    # test "minimal case: :error" do
    #   expected = [
    #     %{
    #       bindings: [input: :error],
    #       line: 5,
    #       piped_value: nil,
    #       label: :def_input
    #     },
    #     %{
    #       bindings: [input: :error],
    #       line: 8,
    #       piped_value: "It was error",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input: :error],
    #       line: 9,
    #       piped_value: "It was error",
    #       label: :def_output
    #     },
    #   ]
    #   Support.CaseStatement.Minimal.as_a_single_vanilla_statement(:error)

    #   assert_events_match_repo(expected)
    # end

    # test "minimal case piped into: :ok" do
    #   expected = [
    #     %{
    #       bindings: [input: :ok],
    #       line: 12,
    #       piped_value: nil,
    #       label: :def_input
    #     },
    #     %{
    #       bindings: [input: :ok],
    #       line: 15,
    #       piped_value: "It was ok",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input: :ok],
    #       line: 17,
    #       piped_value: "It was ok",
    #       label: :def_output
    #     },
    #   ]
    #   Support.CaseStatement.Minimal.as_a_single_vanilla_statement_piped_into(:ok)

    #   assert_events_match_repo(expected)
    # end

    # test "minimal case piped into: :error" do
    #   expected = [
    #     %{
    #       bindings: [input: :error],
    #       line: 12,
    #       piped_value: nil,
    #       label: :def_input
    #     },
    #     %{
    #       bindings: [input: :error],
    #       line: 16,
    #       piped_value: "It was error",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input: :error],
    #       line: 17,
    #       piped_value: "It was error",
    #       label: :def_output
    #     },
    #   ]
    #   Support.CaseStatement.Minimal.as_a_single_vanilla_statement_piped_into(:error)

    #   assert_events_match_repo(expected)
    # end

    # test "minimal case with plenty enumeration: :ok" do
    #   expected = [
    #     %{
    #       bindings: [input: :ok],
    #       line: 20,
    #       piped_value: nil,
    #       label: :def_input
    #     },
    #     %{
    #       bindings: [input: :ok, r: :ok],
    #       line: 22,
    #       piped_value: "It was ok",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input: :ok],
    #       line: 27,
    #       piped_value: "It was ok",
    #       label: :def_output
    #     },
    #   ]
    #   Support.CaseStatement.Minimal.as_a_long_single_vanilla_statement(:ok)

    #   assert_events_match_repo(expected)
    # end

    # test "minimal case with plenty enumeration: 2" do
    #   expected = [
    #     %{
    #       bindings: [input: 2],
    #       line: 20,
    #       piped_value: nil,
    #       label: :def_input
    #     },
    #     %{
    #       bindings: [input: 2, r: 2],
    #       line: 25,
    #       piped_value: "It was 2",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input: 2],
    #       line: 27,
    #       piped_value: "It was 2",
    #       label: :def_output
    #     },
    #   ]
    #   Support.CaseStatement.Minimal.as_a_long_single_vanilla_statement(2)

    #   assert_events_match_repo(expected)
    # end

    # test "Elaborate case with several case statements sequentially: :ok, :error, :error" do
    #   expected = [
    #     %{
    #       bindings: [input1: :ok, input2: :error, input3: :error],
    #       line: 34,
    #       piped_value: nil,
    #       label: :def_input
    #     },
    #     %{
    #       bindings: [input1: :ok, input2: :error, input3: :error],
    #       line: 36,
    #       piped_value: "1. It was ok",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input1: :ok, input2: :error, input3: :error],
    #       line: 41,
    #       piped_value: "2. It was error",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input1: :ok, input2: :error, input3: :error],
    #       line: 45,
    #       piped_value: "3. It was error",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input1: :ok, input2: :error, input3: :error],
    #       line: 46,
    #       piped_value: "3. It was error",
    #       label: :def_output
    #     },
    #   ]
    #   Support.CaseStatement.Elaborate.as_several_case_statements_sequentially(:ok, :error, :error)

    #   assert_events_match_repo(expected)
    # end

    # test "Elaborate case with several nested case statements: :error, :ok, :error" do
    #   expected = [
    #     %{
    #       bindings: [input1: :error, input2: :ok, input3: :error],
    #       line: 49,
    #       piped_value: nil,
    #       label: :def_input
    #     },
    #     %{
    #       bindings: [input1: :error, input2: :ok, input3: :error],
    #       line: 65,
    #       piped_value: "3. It was error",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input1: :error, input2: :ok, input3: :error],
    #       line: 66,
    #       piped_value: "3. It was error",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input1: :error, input2: :ok, input3: :error],
    #       line: 71,
    #       piped_value: "3. It was error",
    #       label: :case_statement
    #     },
    #     %{
    #       bindings: [input1: :error, input2: :ok, input3: :error],
    #       line: 72,
    #       piped_value: "3. It was error",
    #       label: :def_output
    #     },
    #   ]
    #   Support.CaseStatement.Elaborate.as_several_nested_case_statements(:error, :ok, :error)

    #   assert_events_match_repo(expected)
    # end

    def assert_events_match_repo(expected) do
      events = ExDebugger.Repo.dump
        |> Enum.map(&elem(&1, 2))

      assert Enum.count(expected) == Enum.count(events)

      expected
      |> Enum.zip(events)
      |> Enum.each(fn {expected, recorded_event} ->
        assert expected.bindings == recorded_event.bindings
        assert expected.line == recorded_event.env.line
        assert expected.label == recorded_event.label
        assert expected.piped_value == recorded_event.piped_value
      end)

      events
      |> Enum.reduce(fn current_event, previous_event ->
        assert current_event.env.file == previous_event.env.file
        assert current_event.env.module == previous_event.env.module
        assert current_event.env.function == previous_event.env.function
        current_event
      end)
    end

  end

  def assert_capture_io(expected, fun) when is_function(fun) do
    actual = fun
      |> capture_io
      |> strip_ansi_escape_codes

    assert actual == expected
  end

  def strip_ansi_escape_codes(str) do
    str
    |> String.replace(~r/\e\[\d*m/, "")
  end
end
