defmodule ExDebugger.AstWalker2 do
  @moduledoc false
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
           __MODULE__.d(unquote(type), __ENV__, binding())
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
    |> IO.inspect(label: :incorporate_piped_debug_expressions)
  end

  def incorporate_piped_debug_expression(expressions, t = %Tokenizer{},
        type: type,
        current_line: l,
        current_counter: i
      ) do
    a = acc(tokenizer: t)
    [last_expression | remainder] = expressions |> Enum.reverse()

    section = Enum.at(t.defs[t.def_line].sections[l], i)

    last_expression
    |> postwalk(a)
    |> elem(0)
    |> pipe_debug_expression(type: type, line: section.end_section)
    |> Kernel.++(Macro.postwalk(remainder, &postwalk(&1, a)) |> elem(0))
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

  def postwalk({operator, ctx, statements}, a = acc()) when is_list(statements) do
    {{operator, ctx,
      Enum.map(statements, fn e ->
        postwalk(e, a) |> elem(0)
      end)}, a}
  end

  def postwalk(rest, a = acc()), do: {rest, a}

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
        acc(tokenizer: t, current_line: l, current_counter: i)
      ) do
    {:__block__, ctx,
     incorporate_piped_debug_expression(statements, t,
       type: :case_statement,
       current_line: l,
       current_counter: i
     )}
  end

  def handle_block(statements, acc(tokenizer: t, current_line: l, current_counter: i)) do
    {:__block__, [],
     incorporate_piped_debug_expression(List.wrap(statements), t,
       type: :case_statement,
       current_line: l,
       current_counter: i
     )}
  end
end
