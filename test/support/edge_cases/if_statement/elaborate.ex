defmodule Support.EdgeCases.IfStatement.Elaborate do
  use ExDebugger

  def as_several_if_statements_sequentially(input1, input2, input3) do
    if input1 do
      "1. It was ok"
    else
      "1. It was error"
    end

    if input2 do
      "2. It was ok"
    else
      "2. It was error"
    end

    if input3 do
      "3. It was ok"
    else
      "3. It was error"
    end
  end

  def as_several_nested_if_statements(input1, input2, input3) do
    if input1 do
      if input2 do
        if input3 do
          "1. It was ok"
        else
          "1. It was error"
        end
      else
        if input3 do
          "2. It was ok"
        else
          "2. It was error"
        end
      end
    else
      if input2 do
        if input3 do
          "3. It was ok"
        else
          "3. It was error"
        end
      else
        if input3 do
          "4. It was ok"
        else
          "4. It was error"
        end
      end
    end
  end
end
