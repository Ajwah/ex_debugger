defmodule Support.EdgeCases.CondStatement.Minimal do
  use ExDebugger
  alias Support.EdgeCases.CondStatement.Helper

  def being_piped_inside_contracted_def_form(input),
    do:
      (cond do
         input == false -> "It was error"
         true -> "It was ok"
       end)

  def as_a_single_vanilla_statement_inside_expanded_def_form(input) do
    cond do
      input == false -> "It was error"
      true -> "It was ok"
    end
  end

  def as_a_single_branch(input) do
    cond do
      input == true -> "It was ok"
    end
  end

  def with_long_branches(input) do
    cond do
      input == true ->
        Helper.rnd()
        Helper.rnd()
        Helper.rnd()
        Helper.rnd()
        5

      input == false ->
        Helper.rnd()
        Helper.rnd()
        Helper.rnd()
        Helper.rnd()
        10
    end
  end
end
