defmodule Support.EdgeCases.UseCases.MainModuleWithExDebuggerUseHelperModuleWithExDebugger do
  @moduledoc false
  use ExDebugger
  use Support.EdgeCases.UseCases.HelperModuleWithExDebugger

  def run(ls, opts \\ [addend: 0, subtrahend: 0, multiplicand: 1, divisor: 1])

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
end
