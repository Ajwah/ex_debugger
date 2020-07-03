defmodule Support.EdgeCases.CondStatement.Elaborate do
  use ExDebugger

  def as_several_cond_statements_sequentially(input1, input2, input3) do
    cond do
      input1 == true -> "1. It was ok"
      true -> "1. It was error"
    end

    cond do
      input2 == true -> "2. It was ok"
      true -> "2. It was error"
    end

    cond do
      input3 == true -> "3. It was ok"
      true -> "3. It was error"
    end
  end

  def as_several_nested_cond_statements(input1, input2, input3) do
    cond do
      input1 == true ->
        cond do
          input2 == true ->
            cond do
              input3 == true -> "1. It was ok"
              true -> "1. It was error"
            end

          true ->
            cond do
              input3 == true -> "2. It was ok"
              true -> "2. It was error"
            end
        end

      true ->
        cond do
          input2 == true ->
            cond do
              input3 == true -> "3. It was ok"
              true -> "3. It was error"
            end

          true ->
            cond do
              input3 == true -> "4. It was ok"
              true -> "4. It was error"
            end
        end
    end
  end
end
