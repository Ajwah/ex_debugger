defmodule ExDebugger.Helpers.Def do
  # Helper Module to assist in annotating `ast` as received by def/defp
  @moduledoc false

  alias ExDebugger.{
    AstWalker,
    Meta,
    Tokenizer
  }

  @default_input_labels %{
    def: :__def_input_only__,
    defp: :__defp_input_only__
  }

  @default_output_labels %{
    def: :def_output_only,
    defp: :defp_output_only
  }

  @doc false
  def default_input_labels, do: @default_input_labels
  def default_input_labels(type), do: Map.fetch!(@default_input_labels, type)

  @doc false
  def default_output_labels, do: @default_output_labels
  def default_output_labels(type), do: Map.fetch!(@default_output_labels, type)

  @doc false
  def annotate(type, caller, def_heading_ast, def_do_block_ast) do
    {updated_def_heading_ast, updated_def_do_block_ast} =
      if Application.get_env(:ex_debugger, :debug_options_file) do
        ex_debugger_opts = ExDebugger.Options.extract(:debug, caller.module)

        if ex_debugger_opts.capture_medium == :none do
          {def_heading_ast, def_do_block_ast}
        else
          annotate_definition(type, caller, def_heading_ast, def_do_block_ast)
        end
      else
        {def_heading_ast, def_do_block_ast}
      end

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

  @doc false
  defp annotate_definition(type, caller, def_heading_ast, def_do_block_ast) do
    tokenizer = Tokenizer.new(caller, def_heading_ast)

    if Tokenizer.module_has_use_ex_debugger?(tokenizer, caller.module) do
      annotate_ast(type, tokenizer, def_heading_ast, def_do_block_ast)
    else
      {def_heading_ast, def_do_block_ast}
    end
  end

  @doc false
  defp annotate_ast(type, tokenizer, def_heading_ast, def_do_block_ast) do
    Meta.debug(tokenizer, tokenizer.meta_debug, tokenizer.def_name, :show_tokenizer)
    Meta.debug(def_do_block_ast, tokenizer.meta_debug, tokenizer.def_name, :show_ast_before)

    updated_def_do_block_ast =
      handle_do_block(
        default_input_labels(type),
        default_output_labels(type),
        def_do_block_ast,
        tokenizer
      )

    Meta.debug(
      updated_def_do_block_ast,
      tokenizer.meta_debug,
      tokenizer.def_name,
      :show_ast_after
    )

    {def_heading_ast, updated_def_do_block_ast}
  end

  @doc false
  defp handle_do_block(input_label, output_label, [do: {:__block__, ctx, statements}], tokenizer) do
    [last_expression | remainder] =
      [
        AstWalker.pipe_debug_expression(nil,
          type: input_label,
          line: tokenizer.def_line
        )
        | if Tokenizer.bifurcates?(tokenizer) do
            AstWalker.incorporate_piped_debug_expressions(statements, tokenizer)
          else
            statements
          end
      ]
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

  @doc false
  defp handle_do_block(input_label, output_label, [do: {op = :|>, ctx, statements}], tokenizer) do
    statements =
      if Tokenizer.bifurcates?(tokenizer) do
        AstWalker.incorporate_piped_debug_expressions(statements, tokenizer)
      else
        statements
      end

    block =
      {op, ctx, statements}
      |> AstWalker.pipe_debug_expression(
        type: output_label,
        line: Tokenizer.last_line(tokenizer)
      )

    [
      do: {
        :__block__,
        ctx,
        [
          AstWalker.pipe_debug_expression(nil,
            type: input_label,
            line: tokenizer.def_line
          )
          | block
        ]
      }
    ]
  end

  @doc false
  defp handle_do_block(input_label, output_label, [do: statement], tokenizer) do
    block =
      if Tokenizer.bifurcates?(tokenizer) do
        AstWalker.incorporate_piped_debug_expressions(statement, tokenizer)
      else
        statement
      end
      |> AstWalker.pipe_debug_expression(
        type: output_label,
        line: Tokenizer.last_line(tokenizer)
      )

    [
      do: {
        :__block__,
        [],
        [
          AstWalker.pipe_debug_expression(nil,
            type: input_label,
            line: tokenizer.def_line
          )
          | block
        ]
      }
    ]
  end
end
