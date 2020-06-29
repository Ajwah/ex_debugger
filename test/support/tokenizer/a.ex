defmodule Support.Tokenizer.A do
  # use ExDebugger.Tokenizer

  def a(i) do
    b = 1

    if i == b do
      :a
    else
      :b
    end

    [1, 2, 3]
    |> Enum.map(fn e ->
      e * 2
    end)

    i
    |> case do
      1 ->
        :a

      _ ->
        b
        |> case do
          1 -> :a
          _ -> :end
        end
    end

    %{b: b}
  end
end
