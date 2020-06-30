defmodule ExDebugger.Def do
  @moduledoc """
  Helper Module to assist in annotating `ast` as received by def/defp
  """
  alias ExDebugger.{
    AstWalker,
    Meta,
    Tokenizer
  }

  @default_output_labels %{
    def: :def_output_only,
    defp: :defp_output_only
  }

  def default_output_labels, do: @default_output_labels
  def default_output_labels(type), do: Map.fetch!(@default_output_labels, type)

  def annotate(type, caller, def_heading_ast, def_do_block_ast) do
    {updated_def_heading_ast, updated_def_do_block_ast} =
      annotate_definition(type, caller, def_heading_ast, def_do_block_ast)

    type
    |> case do
      :def ->
        quote do
          Kernel.def(unquote(updated_def_heading_ast), unquote(updated_def_do_block_ast))
        end

      :defp ->
        quote do
          Kernel.defp(unquote(updated_def_heading_ast), unquote(updated_def_do_block_ast))
        end

      wrong_usage ->
        raise "[Developer Error] Incorrect type provided: #{wrong_usage}"
    end
  end

  defp annotate_definition(type, caller, def_heading_ast, def_do_block_ast) do
    tokenizer = Tokenizer.new(caller, def_heading_ast)

    if Tokenizer.module_has_use_ex_debugger?(tokenizer, caller.module) do
      annotate_ast(type, tokenizer, def_heading_ast, def_do_block_ast)
    else
      {def_heading_ast, def_do_block_ast}
    end
  end

  defp annotate_ast(type, tokenizer, def_heading_ast, def_do_block_ast) do
    Meta.debug(tokenizer, tokenizer.meta_debug, tokenizer.def_name, :show_tokenizer)
    Meta.debug(def_do_block_ast, tokenizer.meta_debug, tokenizer.def_name, :show_ast_before)

    updated_def_do_block_ast =
      handle_do_block(Map.fetch!(@default_output_labels, type), def_do_block_ast, tokenizer)

    Meta.debug(
      updated_def_do_block_ast,
      tokenizer.meta_debug,
      tokenizer.def_name,
      :show_ast_after
    )

    {def_heading_ast, updated_def_do_block_ast}
  end

  defp handle_do_block(output_label, [do: {:__block__, ctx, statements}], tokenizer) do
    [last_expression | remainder] =
      if Tokenizer.bifurcates?(tokenizer) do
        AstWalker.incorporate_piped_debug_expressions(statements, tokenizer)
      else
        statements
      end
      |> Enum.reverse()

    [
      do: {
        :__block__,
        ctx,
        Enum.reverse(remainder) ++
          AstWalker.pipe_debug_expression(last_expression,
            type: output_label,
            line: Tokenizer.last_line(tokenizer)
          )
      }
    ]
  end

  defp handle_do_block(output_label, [do: statement = {op = :|>, ctx, statements}], tokenizer) do
    [
      do: {
        :__block__,
        ctx,
        if Tokenizer.bifurcates?(tokenizer) do
          {op, ctx, AstWalker.incorporate_piped_debug_expressions(statements, tokenizer)}
        else
          statement
        end
        |> AstWalker.pipe_debug_expression(
          type: output_label,
          line: Tokenizer.last_line(tokenizer)
        )
      }
    ]
  end

  defp handle_do_block(output_label, [do: statement], tokenizer) do
    [
      do: {
        :__block__,
        [],
        if Tokenizer.bifurcates?(tokenizer) do
          AstWalker.incorporate_piped_debug_expressions(statement, tokenizer)
        else
          statement
        end
        |> AstWalker.pipe_debug_expression(
          type: output_label,
          line: Tokenizer.last_line(tokenizer)
        )
      }
    ]
  end
end
