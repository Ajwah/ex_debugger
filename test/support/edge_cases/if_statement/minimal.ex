defmodule Support.EdgeCases.IfStatement.Minimal do
  use ExDebugger

  def being_piped_inside_contracted_def_form(input),
    do:
      input
      |> (if do
            "It was ok"
          else
            "It was error"
          end)

  def as_a_single_vanilla_statement_inside_expanded_def_form(input) do
    if input do
      "It was ok"
    else
      "It was error"
    end
  end

  def as_a_single_branch(input) do
    if input do
      "It was ok"
    end
  end
end
