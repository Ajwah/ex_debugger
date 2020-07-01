defmodule Support.EdgeCases.ImportCases.HelperModuleWithExDebugger do
  @moduledoc false
  use ExDebugger

  def calculate(:addend, a, b), do: a + b
  def calculate(:subtrahend, a, b), do: a - b
  def calculate(:multiplicand, a, b), do: a * b
  def calculate(:divisor, a, b), do: a / b

  def calculate(unsupported_operator, _, _),
    do: raise("Unsupported Operator: #{inspect(unsupported_operator)}")
end
