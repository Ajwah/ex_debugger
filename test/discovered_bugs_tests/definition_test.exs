defmodule DiscoveredBugsTests.DefinitionTest do
  alias ExDebugger.Tokenizer.Definition

  @moduledoc """
  Wrong name was derived when definition had `when` incorporated into it.

  Ensure that all possible permutations succeed:
    * Conventional Possibilities:
      * Contracted Form
      * Expanded Form
      * Contracted Form With When
      * Expanded Form With When

    * Unconventional Possibilities
      * Contracted Form Without Line Number
      * Expanded Form Without Line Number
      * Contracted Form Without Line Number But With When
      * Expanded Form Without Line Number But With When

    In the latter case, the line number returned should default to: #{
    Definition.default_def_line()
  }
  """

  use ExUnit.Case, async: false

  describe "#name_and_line When Line Number Set" do
    setup do
      {:ok, %{expected: %{def_name: :a, def_line: 1}}}
    end

    test "Contracted Form", ctx do
      quote line: ctx.expected.def_line do
        def a, do: 1
      end
      |> assert_def_name_line_match(ctx.expected)
    end

    test "Expanded Form", ctx do
      quote line: ctx.expected.def_line do
        def a do
          b = 1
          c = 2

          if b == c do
            :ok
          else
            :not_ok
          end
        end
      end
      |> assert_def_name_line_match(ctx.expected)
    end

    test "Contracted Form With When", ctx do
      quote line: ctx.expected.def_line do
        def a(b, c, d) when is_integer(b) and is_integer(c) and is_integer(d), do: b + c + d
      end
      |> assert_def_name_line_match(ctx.expected)
    end

    test "Expanded Form With When", ctx do
      quote line: ctx.expected.def_line do
        def a(b, c, d) when is_integer(b) and is_integer(c) and is_integer(d) do
          if b - d == c do
            :ok
          else
            :not_ok
          end
        end
      end
      |> assert_def_name_line_match(ctx.expected)
    end
  end

  describe "#name_and_line Without Line Number Set" do
    setup do
      {:ok, %{expected: %{def_name: :a, def_line: Definition.default_def_line()}}}
    end

    test "Contracted Form", ctx do
      quote do
        def a, do: 1
      end
      |> assert_def_name_line_match(ctx.expected)
    end

    test "Expanded Form", ctx do
      quote do
        def a do
          b = 1
          c = 2

          if b == c do
            :ok
          else
            :not_ok
          end
        end
      end
      |> assert_def_name_line_match(ctx.expected)
    end

    test "Contracted Form With When", ctx do
      quote do
        def a(b, c, d) when is_integer(b) and is_integer(c) and is_integer(d), do: b + c + d
      end
      |> assert_def_name_line_match(ctx.expected)
    end

    test "Expanded Form With When", ctx do
      quote do
        def a(b, c, d) when is_integer(b) and is_integer(c) and is_integer(d) do
          if b - d == c do
            :ok
          else
            :not_ok
          end
        end
      end
      |> assert_def_name_line_match(ctx.expected)
    end
  end

  defp assert_def_name_line_match(ast, expected) do
    actual =
      ast
      |> def_heading_ast
      |> Definition.name_and_line()

    assert expected_tuple(expected) == actual
  end

  defp expected_tuple(%{def_name: def_name, def_line: def_line}), do: {def_name, def_line}
  defp def_heading_ast({:def, _, [def_heading_ast, _def_do_block_ast]}), do: def_heading_ast
end
