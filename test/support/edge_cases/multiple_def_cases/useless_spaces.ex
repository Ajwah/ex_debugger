defmodule Support.EdgeCases.MultipleDefCases.UselessSpaces do
  @moduledoc false
  use ExDebugger





  def run1, do: %{ls: [1, 2, 3, 4]}
    |> Map.fetch!(:ls)
    |> List.wrap


    |> Enum.reverse
    |> Enum.reduce(0, &((&1 * 2) + &2))

  def run2(%{digit: a}, %{digit: b}, %{digit: c}, %{digit: d}) do

    %{ls: [a, b, c, d]}
    |> Map.fetch!(:ls)




             |> List.wrap

     |> Enum.reverse
      |> Enum.reduce(0, &((&1 * 2) + &2))






                 end









  def run3(a, b, c, d) when is_integer(a) and is_integer(b) and is_integer(c) and is_integer(d) do







    %{ls: [a, b, c, d]}
    |> Map.fetch!(:ls)
    |> List.wrap
    |> Enum.reverse
    |> Enum.reduce(0, &((&1 * 2) + &2))







  end

def run4(a) do
    %{ls: a}
    |> Map.fetch!(:ls)

    |> List.wrap

    |> Enum.reverse

    |> Enum.reduce(0, &((&1 * 2) + &2)) end












end
