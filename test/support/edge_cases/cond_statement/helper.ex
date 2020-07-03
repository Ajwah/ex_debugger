defmodule Support.EdgeCases.CondStatement.Helper do
  @moduledoc false
  def rnd, do: Enum.random(1..1_000_000_000_000)
end
