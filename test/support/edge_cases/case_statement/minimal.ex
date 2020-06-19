defmodule Support.EdgeCases.CaseStatement.Minimal do
  use ExDebugger

  def being_piped_inside_contracted_def_form(input), do: (input
    |> case do
      :ok -> "It was ok"
      :error -> "It was error"
    end)

  def as_a_single_vanilla_statement_inside_expanded_def_form(input) do
    case input do
      :ok -> "It was ok"
      :error -> "It was error"
    end
  end

  def as_a_long_single_vanilla_statement(input) do
    case input do
      r = :ok -> "It was #{r}"
      r = :error -> "It was #{r}"
      r = 1 -> "It was #{r}"
      r = 2 -> "It was #{r}"
      r = 3 -> "It was #{r}"
    end
  end
end
