defmodule ExDebugger.AstWalker do
  @moduledoc """
  Walks the AST and annotates accordingly.
  """

  alias ExDebugger.Tokenizer
  import Record

  defrecord :acc,
    tokenizer: %{},
    current_line: 0,
    current_counter: 0

  def inc(a = acc(current_counter: current_counter)),
    do: acc(a, current_counter: current_counter + 1)

  def pipe_debug_expression(expression, type: type, line: line) do
    [
      {:|>, [],
       [
         expression,
         quote line: line do
           __MODULE__.d(unquote(type), __ENV__, binding(), false)
         end
       ]}
    ]
  end

  def incorporate_piped_debug_expressions(expressions, t = %Tokenizer{})
      when is_list(expressions) do
    expressions
    |> Macro.postwalk(acc(tokenizer: t), &postwalk/2)
    |> elem(0)
  end

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

  def postwalk({:if, ctx = [{:line, line} | _], [blocks]}, a = acc()),
    do: {{:if, ctx, [handle_if_scenarios(blocks, line, a)]}, a}

  def postwalk({:if, ctx, [condition = {_, [line: line], _}, blocks]}, a = acc()),
    do: {{:if, ctx, [condition, handle_if_scenarios(blocks, line, a)]}, a}

  def postwalk(rest, a = acc()), do: {rest, a}

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
                 incorporate_piped_debug_expression(statements, a, type: :if_statement)}
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
                 incorporate_piped_debug_expression([statement], a, type: :if_statement)}
              }
            ]
        }
    end)
    |> elem(1)
  end

  def handle_case_scenarios(case_scenarios, a = acc()) do
    case_scenarios
    |> Enum.reduce({a, []}, fn e, {a, handled_case_scenarios} ->
      {inc(a), [handle_case_scenario(e, a) | handled_case_scenarios]}
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  def handle_case_scenario({:->, ctx, [matcher, block]}, a = acc()) do
    {:->, ctx, [matcher, handle_block(block, a)]}
  end

  def handle_block(
        {:__block__, ctx, statements},
        a = acc()
      ) do
    {:__block__, ctx, incorporate_piped_debug_expression(statements, a, type: :case_statement)}
  end

  def handle_block(statements, a = acc()) do
    {:__block__, [],
     incorporate_piped_debug_expression(List.wrap(statements), a, type: :case_statement)}
  end
end
