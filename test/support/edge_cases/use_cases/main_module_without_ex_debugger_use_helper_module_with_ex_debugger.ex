defmodule Support.EdgeCases.UseCases.MainModuleWithoutExDebuggerUseHelperModuleWithExDebugger do
  @moduledoc """
  I am surprised to learn here that the `use ExDebugger` from `HelperModuleWithExDebugger` has no effect.
  This seems to indicate to me that `use` in this case only comes about after `def` macro has been invoked.
  """
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
