defmodule ExDebugger.Tokenizer.Definition do
  @moduledoc false

  def all(tokens) do
    tokens
    |> Enum.drop_while(fn
      {:identifier, _, :def} -> false
      _ -> true
    end)
    |> Enum.chunk_while(
      {:none, []},
      fn
        e = {:identifier, {_, def_indentation_level, _}, :def}, {i, acc} ->
          {:cont, normalize(acc, i), {def_indentation_level, [e]}}

        e, {def_indentation_level, acc} ->
          {:cont, {def_indentation_level, [e | acc]}}
      end,
      fn
        [] -> {:cont, []}
        {i, acc} -> {:cont, normalize(acc, i), []}
      end
    )
    |> Enum.drop(1)
  end

  def normalize(tokens, def_indentation_level) do
    tokens
    |> trim_beyond_end(def_indentation_level)
    |> Enum.reverse()
    |> strip_wrong_indentations(def_indentation_level)
    |> trim_ending(def_indentation_level)
    |> Enum.reverse()
  end

  def strip_wrong_indentations([], _), do: []
  def strip_wrong_indentations(ls = [_], _), do: ls

  def strip_wrong_indentations([{:identifier, _, :def} | _] = tokens, def_indentation_level) do
    tokens
    |> Enum.reduce({:include, []}, fn
      e = {:identifier, {_, _, _}, :def}, {_, a} ->
        {:include, [e | a]}

      e = {:end, {_, _, _}}, {_, a} ->
        {:include, [e | a]}

      _ = {:eol, {_, _, _}}, {_, a} ->
        {:include, a}

      _, {:exclude, a} ->
        {:exclude, a}

      e = {_, {_, indentation_level, _}, _}, {:include, a} ->
        if indentation_level > def_indentation_level do
          {:include, [e | a]}
        else
          {:exclude, a}
        end

      e = {_, {_, indentation_level, _}}, {:include, a} ->
        if indentation_level > def_indentation_level do
          {:include, [e | a]}
        else
          {:exclude, a}
        end
    end)
    |> elem(1)
  end

  def trim_beyond_end([], _), do: []

  def trim_beyond_end(tokens, def_indentation_level) do
    result_so_far =
      tokens
      |> Enum.drop_while(fn
        {:end, _} -> false
        _ -> true
      end)
      |> case do
        [] -> convert_eol_to_end(tokens, def_indentation_level)
        r -> r
      end

    result_so_far
    |> Enum.drop_while(fn
      {:end, {_, ^def_indentation_level, _}} -> false
      _ -> true
    end)
    |> case do
      [] -> result_so_far
      r -> r
    end
  end

  def convert_eol_to_end([{:eol, {x, _, _}} | tl], def_indentation_level),
    do: [{:end, {x, def_indentation_level, :missing_end}} | tl]

  def trim_ending(ls = [], _), do: ls
  def trim_ending(ls = [_], _), do: ls
  def trim_ending(ls = [_, _], _), do: ls

  def trim_ending(
        [end_token = {:end, {_, _, _}}, last_line = {_, {lx, _, _}} | tl],
        def_indentation_level
      ),
      do: trim_ending(lx, end_token, def_indentation_level, last_line, tl)

  def trim_ending(
        [end_token = {:end, {_, _, _}}, last_line = {_, {lx, _, _}, _} | tl],
        def_indentation_level
      ),
      do: trim_ending(lx, end_token, def_indentation_level, last_line, tl)

  def trim_ending(lx, {:end, {x, y, tag}}, def_indentation_level, last_line, tl) do
    if tag == :missing_end do
      [{:end, {x, y, nil}}, last_line | tl]
    else
      [{:end, {lx + 1, def_indentation_level, nil}}, last_line | tl]
    end
  end
end

# q = [
#   {:identifier, {1, 1, nil}, :defmodule},
#   {:alias, {1, 11, nil}, :Support},
#   {:., {1, 18, nil}},
#   {:alias, {1, 19, nil}, :CaseStatement},
#   {:., {1, 32, nil}},
#   {:alias, {1, 33, nil}, :Elaborate},
#   {:do, {1, 43, nil}},
#   {:eol, {1, 45, 1}},
#   {:at_op, {2, 3, nil}, :@},
#   {:identifier, {2, 4, nil}, :moduledoc},
#   {false, {2, 14, nil}},
#   {:eol, {2, 19, 1}},
#   {:identifier, {3, 3, nil}, :use},
#   {:alias, {3, 7, nil}, :ExDebugger2},
#   {:eol, {3, 18, 2}},
#   {:identifier, {5, 3, nil}, :def},
#   {:paren_identifier, {5, 7, nil}, :as_several_case_statements_sequentially},
#   {:"(", {5, 46, nil}},
#   {:identifier, {5, 47, nil}, :input1},
#   {:",", {5, 53, 0}},
#   {:identifier, {5, 55, nil}, :input2},
#   {:",", {5, 61, 0}},
#   {:identifier, {5, 63, nil}, :input3},
#   {:")", {5, 69, nil}},
#   {:do, {5, 71, nil}},
#   {:eol, {5, 73, 1}},
#   {:alias, {6, 5, nil}, :IO},
#   {:., {6, 7, nil}},
#   {:paren_identifier, {6, 8, nil}, :inspect},
#   {:"(", {6, 15, nil}},
#   {:at_op, {6, 16, nil}, :@},
#   {:identifier, {6, 17, nil}, :tokens},
#   {:",", {6, 23, 0}},
#   {:kw_identifier, {6, 25, nil}, :label},
#   {:atom, {6, 32, nil}, :tokens},
#   {:",", {6, 39, 0}},
#   {:kw_identifier, {6, 41, nil}, :limit},
#   {:atom, {6, 48, nil}, :infinity},
#   {:")", {6, 57, nil}},
#   {:eol, {6, 58, 1}},
#   {:identifier, {7, 5, nil}, :case},
#   {:do_identifier, {7, 10, nil}, :input1},
#   {:do, {7, 17, nil}},
#   {:eol, {7, 19, 1}},
#   {:atom, {8, 7, nil}, :ok},
#   {:stab_op, {8, 11, nil}, :->},
#   {:bin_string, {8, 14, nil}, ["1. It was ok"]},
#   {:eol, {8, 28, 1}},
#   {:atom, {9, 7, nil}, :error},
#   {:stab_op, {9, 14, nil}, :->},
#   {:bin_string, {9, 17, nil}, ["1. It was error"]},
#   {:eol, {9, 34, 1}},
#   {:end, {10, 5, nil}},
#   {:eol, {10, 8, 1}},
#   {:identifier, {11, 5, nil}, :case},
#   {:do_identifier, {11, 10, nil}, :input2},
#   {:do, {11, 17, nil}},
#   {:eol, {11, 19, 1}},
#   {:atom, {12, 7, nil}, :ok},
#   {:stab_op, {12, 11, nil}, :->},
#   {:bin_string, {12, 14, nil}, ["2. It was ok"]},
#   {:eol, {12, 28, 1}},
#   {:atom, {13, 7, nil}, :error},
#   {:stab_op, {13, 14, nil}, :->},
#   {:bin_string, {13, 17, nil}, ["2. It was error"]},
#   {:eol, {13, 34, 1}},
#   {:end, {14, 5, nil}},
#   {:eol, {14, 8, 1}},
#   {:identifier, {15, 5, nil}, :case},
#   {:do_identifier, {15, 10, nil}, :input3},
#   {:do, {15, 17, nil}},
#   {:eol, {15, 19, 1}},
#   {:atom, {16, 7, nil}, :ok},
#   {:stab_op, {16, 11, nil}, :->},
#   {:bin_string, {16, 14, nil}, ["3. It was ok"]},
#   {:eol, {16, 28, 1}},
#   {:atom, {17, 7, nil}, :error},
#   {:stab_op, {17, 14, nil}, :->},
#   {:bin_string, {17, 17, nil}, ["3. It was error"]},
#   {:eol, {17, 34, 1}},
#   {:end, {18, 5, nil}},
#   {:eol, {18, 8, 1}},
#   {:end, {19, 3, nil}},
#   {:eol, {19, 6, 2}},
#   {:identifier, {21, 3, nil}, :def},
#   {:paren_identifier, {21, 7, nil}, :as_several_nested_case_statements},
#   {:"(", {21, 40, nil}},
#   {:identifier, {21, 41, nil}, :input1},
#   {:",", {21, 47, 0}},
#   {:identifier, {21, 49, nil}, :input2},
#   {:",", {21, 55, 0}},
#   {:identifier, {21, 57, nil}, :input3},
#   {:")", {21, 63, nil}},
#   {:do, {21, 65, nil}},
#   {:eol, {21, 67, 1}},
#   {:identifier, {22, 5, nil}, :case},
#   {:do_identifier, {22, 10, nil}, :input1},
#   {:do, {22, 17, nil}},
#   {:eol, {22, 19, 1}},
#   {:atom, {23, 7, nil}, :ok},
#   {:stab_op, {23, 11, nil}, :->},
#   {:identifier, {23, 14, nil}, :case},
#   {:do_identifier, {23, 19, nil}, :input2},
#   {:do, {23, 26, nil}},
#   {:eol, {23, 28, 1}},
#   {:atom, {24, 9, nil}, :ok},
#   {:stab_op, {24, 13, nil}, :->},
#   {:identifier, {24, 16, nil}, :case},
#   {:do_identifier, {24, 21, nil}, :input3},
#   {:do, {24, 28, nil}},
#   {:eol, {24, 30, 1}},
#   {:atom, {25, 13, nil}, :ok},
#   {:stab_op, {25, 17, nil}, :->},
#   {:bin_string, {25, 20, nil}, ["1. It was ok"]},
#   {:eol, {25, 34, 1}},
#   {:atom, {26, 13, nil}, :error},
#   {:stab_op, {26, 20, nil}, :->},
#   {:bin_string, {26, 23, nil}, ["1. It was error"]},
#   {:eol, {26, 40, 1}},
#   {:end, {27, 11, nil}},
#   {:eol, {27, 14, 1}},
#   {:atom, {28, 9, nil}, :error},
#   {:stab_op, {28, 16, nil}, :->},
#   {:identifier, {28, 19, nil}, :case},
#   {:do_identifier, {28, 24, nil}, :input3},
#   {:do, {28, 31, nil}},
#   {:eol, {28, 33, 1}},
#   {:atom, {29, 13, nil}, :ok},
#   {:stab_op, {29, 17, nil}, :->},
#   {:bin_string, {29, 20, nil}, ["2. It was ok"]},
#   {:eol, {29, 34, 1}},
#   {:atom, {30, 13, nil}, :error},
#   {:stab_op, {30, 20, nil}, :->},
#   {:bin_string, {30, 23, nil}, ["2. It was error"]},
#   {:eol, {30, 40, 1}},
#   {:end, {31, 11, nil}},
#   {:eol, {31, 14, 1}},
#   {:end, {32, 9, nil}},
#   {:eol, {32, 12, 2}},
#   {:atom, {34, 7, nil}, :error},
#   {:stab_op, {34, 14, nil}, :->},
#   {:identifier, {34, 17, nil}, :case},
#   {:do_identifier, {34, 22, nil}, :input2},
#   {:do, {34, 29, nil}},
#   {:eol, {34, 31, 1}},
#   {:atom, {35, 9, nil}, :ok},
#   {:stab_op, {35, 13, nil}, :->},
#   {:identifier, {35, 16, nil}, :case},
#   {:do_identifier, {35, 21, nil}, :input3},
#   {:do, {35, 28, nil}},
#   {:eol, {35, 30, 1}},
#   {:atom, {36, 13, nil}, :ok},
#   {:stab_op, {36, 17, nil}, :->},
#   {:bin_string, {36, 20, nil}, ["3. It was ok"]},
#   {:eol, {36, 34, 1}},
#   {:atom, {37, 13, nil}, :error},
#   {:stab_op, {37, 20, nil}, :->},
#   {:bin_string, {37, 23, nil}, ["3. It was error"]},
#   {:eol, {37, 40, 1}},
#   {:end, {38, 11, nil}},
#   {:eol, {38, 14, 1}},
#   {:atom, {39, 9, nil}, :error},
#   {:stab_op, {39, 16, nil}, :->},
#   {:identifier, {39, 19, nil}, :case},
#   {:do_identifier, {39, 24, nil}, :input3},
#   {:do, {39, 31, nil}},
#   {:eol, {39, 33, 1}},
#   {:atom, {40, 13, nil}, :ok},
#   {:stab_op, {40, 17, nil}, :->},
#   {:bin_string, {40, 20, nil}, ["4. It was ok"]},
#   {:eol, {40, 34, 1}},
#   {:atom, {41, 13, nil}, :error},
#   {:stab_op, {41, 20, nil}, :->},
#   {:bin_string, {41, 23, nil}, ["4. It was error"]},
#   {:eol, {41, 40, 1}},
#   {:end, {42, 11, nil}},
#   {:eol, {42, 14, 1}},
#   {:end, {43, 9, nil}},
#   {:eol, {43, 12, 1}},
#   {:end, {44, 5, nil}},
#   {:eol, {44, 8, 1}},
#   {:end, {45, 3, nil}},
#   {:eol, {45, 6, 1}},
#   {:end, {46, 1, nil}},
#   {:eol, {46, 4, 1}}
# ]
