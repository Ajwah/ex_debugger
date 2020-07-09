defmodule ExDebugger.AstWalker do
  # Walks the AST and annotates accordingly.
  @moduledoc false
  import Record

  defrecord :acc,
    tokenizer: %{},
    current_line: 0,
    current_counter: 0

  alias ExDebugger.Tokenizer

  @default_polyfurcation_labels %{
    case: :case_statement,
    if: :if_statement,
    cond: :cond_statement
  }

  @doc false
  def default_polyfurcation_labels(type), do: Map.fetch!(@default_polyfurcation_labels, type)

  @doc false
  def inc(a = acc(current_counter: current_counter)),
    do: acc(a, current_counter: current_counter + 1)

  @doc false
  def debug_expression_piped_into(type, line) do
    quote line: line do
      __MODULE__.d(unquote(type), __ENV__, binding(), false)
    end
  end

  @doc false
  def pipe_debug_expression(expression = {:|, _, _}, type: type, line: line) do
    pipe_debug_expression([expression], type: type, line: line)
  end

  def pipe_debug_expression(expression, type: type, line: line) do
    [
      {:|>, [], [expression, debug_expression_piped_into(type, line)]}
    ]
  end

  @doc false
  def incorporate_piped_debug_expressions(expressions, t = %Tokenizer{})
      when is_list(expressions) do
    expressions
    |> Macro.postwalk(acc(tokenizer: t), &postwalk/2)
    |> elem(0)
  end

  @doc false
  def incorporate_piped_debug_expressions({op, ctx, expressions}, t = %Tokenizer{})
      when is_list(expressions) do
    [result] =
      incorporate_piped_debug_expressions(
        [
          {
            op,
            ctx,
            expressions
          }
        ],
        t
      )

    result
  end

  @doc false
  def incorporate_piped_debug_expression(
        expressions,
        acc(tokenizer: t, current_line: l, current_counter: i),
        type: type
      ) do
    [last_expression | remainder] = expressions |> Enum.reverse()

    section = Enum.at(t.defs[t.def_line].sections[l], i)

    last_expression
    |> pipe_debug_expression(type: type, line: section.end_section)
    |> Kernel.++(remainder)
    |> Enum.reverse()
  end

  @doc false
  def postwalk({:case, ctx = [line: current_line], do_clause}, a = acc()) do
    do_clause
    |> case do
      # piped into case scenario
      [[do: case_scenarios]] ->
        {{:case, ctx,
          [[do: handle_case_scenarios(case_scenarios, acc(a, current_line: current_line))]]}, a}

      # classic case scenario with expression embedded therein
      [embedded_expression, [do: case_scenarios]] ->
        {{:case, ctx,
          [
            embedded_expression,
            [do: handle_case_scenarios(case_scenarios, acc(a, current_line: current_line))]
          ]}, a}
    end
  end

  @doc false
  def postwalk({:cond, ctx = [{:line, current_line} | _], [[do: blocks]]}, a = acc()),
    do:
      {{:cond, ctx, [[do: handle_cond_scenarios(blocks, acc(a, current_line: current_line))]]}, a}

  @doc false
  def postwalk({:if, ctx = [{:line, line} | _], [blocks]}, a = acc()),
    do: {{:if, ctx, [handle_if_scenarios(blocks, line, a)]}, a}

  @doc false
  def postwalk({:if, ctx, [condition = {_, [line: line], _}, blocks]}, a = acc()),
    do: {{:if, ctx, [condition, handle_if_scenarios(blocks, line, a)]}, a}

  @doc false
  def postwalk(rest, a = acc()), do: {rest, a}

  @doc false
  def handle_if_scenarios(blocks, line, a = acc()) do
    blocks
    |> Enum.reduce({acc(a, current_line: line, current_counter: 0), []}, fn
      {key, {:__block__, ctx, statements}}, {a = acc(), updated_blocks} ->
        {
          inc(a),
          updated_blocks ++
            [
              {
                key,
                {:__block__, ctx,
                 incorporate_piped_debug_expression(statements, a,
                   type: default_polyfurcation_labels(:if)
                 )}
              }
            ]
        }

      {key, statement}, {a = acc(), updated_blocks} ->
        {
          inc(a),
          updated_blocks ++
            [
              {
                key,
                {:__block__, [],
                 incorporate_piped_debug_expression([statement], a,
                   type: default_polyfurcation_labels(:if)
                 )}
              }
            ]
        }
    end)
    |> elem(1)
  end

  @doc false
  def handle_case_scenarios(case_scenarios, a = acc()) do
    case_scenarios
    |> Enum.reduce({a, []}, fn e, {a, handled_case_scenarios} ->
      {inc(a), [handle_case_scenario(e, a) | handled_case_scenarios]}
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  @doc false
  def handle_cond_scenarios(cond_scenarios, a = acc()) do
    cond_scenarios
    |> Enum.reduce({a, []}, fn e, {a, handled_cond_scenarios} ->
      {inc(a), [handle_cond_scenario(e, a) | handled_cond_scenarios]}
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  @doc false
  def handle_case_scenario({:->, ctx, [matcher, block]}, a = acc()) do
    {:->, ctx, [matcher, handle_block(block, a, type: default_polyfurcation_labels(:case))]}
  end

  @doc false
  def handle_cond_scenario({:->, ctx, [matcher, block]}, a = acc()) do
    {:->, ctx, [matcher, handle_block(block, a, type: default_polyfurcation_labels(:cond))]}
  end

  @doc false
  def handle_block(
        {:__block__, ctx, statements},
        a = acc(),
        type: type
      ) do
    {:__block__, ctx, incorporate_piped_debug_expression(statements, a, type: type)}
  end

  @doc false
  def handle_block(statements, a = acc(), type: type) do
    {:__block__, [], incorporate_piped_debug_expression(List.wrap(statements), a, type: type)}
  end
end
