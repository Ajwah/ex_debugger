defmodule Support.EdgeCases.MultipleDefCases.DefaultParamWithPrivateHelpers do
  @moduledoc false
  use ExDebugger
  @default_arg [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1]

  def default_arg, do: @default_arg

  def run(ls, opts \\ @default_arg)

  def run(ls, opts) do
    ls
    |> Enum.map(fn e ->
      opts
      |> Enum.reduce(e, fn
        {operator, amount}, a -> calculate(operator, a, amount)
        _, _ -> raise "Operator missing"
      end)
    end)
  end

  defp calculate(:addend, a, b), do: a + b
  defp calculate(:subtrahend, a, b), do: a - b
  defp calculate(:multiplicand, a, b), do: a * b
  defp calculate(:divisor, a, b), do: a / b

  defp calculate(unsupported_operator, _, _),
    do: raise("Unsupported Operator: #{inspect(unsupported_operator)}")
end
