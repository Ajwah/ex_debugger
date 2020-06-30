defmodule Support.EdgeCases.CaseStatement.Elaborate do
  @moduledoc false
  use ExDebugger

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
