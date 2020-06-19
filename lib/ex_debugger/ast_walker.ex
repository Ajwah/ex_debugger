defmodule ExDebugger.AstWalker do
  @moduledoc false

  def handle_bifurcation({:if, ctx, [condition = {_, [line: line], _}, blocks]}) do
    {updated_blocks, _} =
      blocks
      |> Enum.reduce({[], line}, fn
        {key, {:__block__, ctx, statements}}, {updated_blocks, line_count} ->
          count = Enum.count(statements) + line_count
          {
            updated_blocks ++ [
              {key, {:__block__, ctx, incorporate_piped_debug_statement(statements, ctx, String.to_atom("if_#{key}"), 0, count)}}
            ],
            count + 1
          }

        {key, statement}, {updated_blocks, line_count} ->
          count = 1 + line_count
          {
            updated_blocks ++ [
              {key, {:__block__, [], incorporate_piped_debug_statement([statement], ctx, String.to_atom("if_#{key}"), 0, count)}}
            ],
            count + 1
          }

      end)
    {:if, ctx, [condition, updated_blocks]}
  end
  def handle_bifurcation({:case, ctx, do_clause}) do
    do_clause
    |> IO.inspect(label: :do_clause)
    |> case do
      # piped into case scenario
      [[do: case_scenarios]] -> {:case, ctx, [[do: Enum.map(case_scenarios, &handle_case_scenario/1)]]}
      # classic case scenario with expression embedded therein
      [embedded_expression, [do: case_scenarios]] -> {:case, ctx, [embedded_expression, [do: Enum.map(case_scenarios, &handle_case_scenario/1)]]}
    end
  end
  def handle_bifurcation({operator, ctx, statements}) when is_list(statements) do
    {operator, ctx, Enum.map(statements, &handle_bifurcation/1)}
  end
  def handle_bifurcation(rest), do: rest

  def handle_case_scenario({:->, ctx, [matcher, block]}) do
    {:->, ctx, [matcher, handle_block(block, ctx)]}
  end

  def handle_block({:__block__, ctx, statements}, parent_ctx) do
    {:__block__, ctx, incorporate_piped_debug_statement(statements, parent_ctx, :case_statement)}
  end
  def handle_block(statements, parent_ctx) do
    {:__block__, [], incorporate_piped_debug_statement(List.wrap(statements), parent_ctx, :case_statement)}
  end

  def incorporate_piped_debug_statement(statements, parent_ctx, statement_juncture, offset \\ 0, last_line \\ false)
  def incorporate_piped_debug_statement([], _, _, _, _), do: []
  def incorporate_piped_debug_statement(statements, parent_ctx, statement_juncture, offset, last_line) do
    reversed = [last_statement | remainder] = Enum.reverse(statements)
    [line: last_line] =
      if last_line do
        [line: last_line]
      else
        reversed
        |> dig_last_ctx
        |> case do
          [] -> parent_ctx
          r -> r
        end
      end

    [
      {:|>, obtain_ctx(last_statement), [
        handle_bifurcation(last_statement),
        quote do
          __MODULE__.d(unquote(statement_juncture), __ENV__, binding())
        end
        |> incorporate_ctx_into_post_debug([line: last_line + offset])
      ]},
    ]
    |> Kernel.++(Macro.postwalk(remainder, &handle_bifurcation/1))
    |> Enum.reverse
  end

  def obtain_ctx({_, ctx, _}), do: ctx
  def obtain_ctx(_), do: []

  def dig_last_ctx(ls) when is_list(ls) do
    ls
    |> Enum.reduce_while([], fn e, a ->
      e
      |> dig_last_ctx
      |> case do
        [] -> {:cont, a}
        ctx -> {:halt, ctx}
      end
    end)
  end
  def dig_last_ctx({:case, ctx, [[do: ls]]}), do: dig_last_ctx({:case, ctx, ls})
  def dig_last_ctx({:case, ctx, [_, [do: ls]]}), do: dig_last_ctx({:case, ctx, ls})
  def dig_last_ctx({_, ctx, ls}) when is_list(ls) do
    ls
    |> Enum.reverse
    |> Enum.reduce_while(ctx, fn e, a ->
      e
      |> dig_last_ctx
      |> case do
        [] -> {:cont, a}
        ctx -> {:halt, ctx}
      end
    end)
  end
  def dig_last_ctx({_, ctx, _}), do: ctx
  def dig_last_ctx(_), do: []

  def incorporate_ctx_into_post_debug({op, _, ls}, ctx) when is_list(ls) do
    {
      op,
      ctx,
      Enum.map(ls, &incorporate_ctx_into_post_debug(&1, ctx))
    }
  end
  def incorporate_ctx_into_post_debug({op, _, e}, ctx), do: {op, ctx, e}
  def incorporate_ctx_into_post_debug(e, _), do: e
end
