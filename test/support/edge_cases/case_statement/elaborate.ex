defmodule Support.CaseStatement.Elaborate do
  @moduledoc false
  use ExDebugger
  # @b 2

  # def test0, do: :q

  # def test1 do
  #   %{a: 2}
  # end

  # @doc ""
  # def test2 do
  #   """
  #   This is a question
  #   What is opinion
  #   """
  # end

  # # This is a comment
  # @doc ""
  # def test3 do
  #   %{a: @b}

  #   36364210

  # end

  # def test4, do: @b
  #   |> List.wrap
  #   |> Enum.reverse

  # @a 1
  def as_several_case_statements_sequentially(input1, input2, input3) do
    case input1 do
      :ok -> "1. It was ok"
      :error -> "1. It was error"
    end

    case input2 do
      :ok -> "2. It was ok"
      :error -> "2. It was error"
    end

    case input3 do
      :ok -> "3. It was ok"
      :error -> "3. It was error"
    end
  end

  def as_several_nested_case_statements(input1, input2, input3) do
    case input1 do
      :ok ->
        case input2 do
          :ok ->
            case input3 do
              :ok -> "1. It was ok"
              :error -> "1. It was error"
            end

          :error ->
            case input3 do
              :ok -> "2. It was ok"
              :error -> "2. It was error"
            end
        end

      :error ->
        case input2 do
          :ok ->
            case input3 do
              :ok -> "3. It was ok"
              :error -> "3. It was error"
            end

          :error ->
            case input3 do
              :ok -> "4. It was ok"
              :error -> "4. It was error"
            end
        end
    end
  end
end
