defmodule Support.EdgeCases.MultipleModules.SingleNestedWithExDebuggerButDebugDisabled do
  @moduledoc "Identical to SingleNestedWithExDebugger except that debug_options has this helpers explicitly disabled"
  use ExDebugger

  defmodule Helpers do
    use ExDebugger

    def calculate(:addend, a, b), do: a + b
    def calculate(:subtrahend, a, b), do: a - b
    def calculate(:multiplicand, a, b), do: a * b
    def calculate(:divisor, a, b), do: a / b

    def calculate(unsupported_operator, _, _),
      do: raise("Unsupported Operator: #{inspect(unsupported_operator)}")
  end

  def run(ls, opts \\ [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1])

  def run(ls, opts) do
    ls
    |> Enum.map(fn e ->
      opts
      |> Enum.reduce(e, fn
        {operator, amount}, a -> Helpers.calculate(operator, a, amount)
        _, _ -> raise "Operator missing"
      end)
    end)
  end
end
