defmodule EdgeCases.EmptyCaseTest do
  @moduledoc """
  This is part of a series of tests to ensure that `use ExDebugger` will
  not lead to stuff breaking down.

  In this case we concern ourselves with an empty module.
  """
  use ExUnit.Case, async: false

  describe "Empty Case: " do
    test "Module is injected with d/5" do
      assert Support.EdgeCases.EmptyCase.__info__(:functions) == [d: 5]
    end
  end
end
