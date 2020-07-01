defmodule Support.EdgeCases.UseCases.HelperModuleWithoutExDebugger do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      def calculate(:addend, a, b), do: a + b
      def calculate(:subtrahend, a, b), do: a - b
      def calculate(:multiplicand, a, b), do: a * b
      def calculate(:divisor, a, b), do: a / b

      def calculate(unsupported_operator, _, _),
        do: raise("Unsupported Operator: #{inspect(unsupported_operator)}")
    end
  end
end
