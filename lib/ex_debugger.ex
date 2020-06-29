defmodule ExDebugger do
  @moduledoc false
  alias ExDebugger.AstWalker2, as: AstWalker

  alias ExDebugger.{
    Meta,
    Tokenizer
  }

  defmacro def(def_heading_ast, def_do_block_ast \\ nil) do
    tokenizer = Tokenizer.new(__CALLER__, def_heading_ast)

    if Tokenizer.module_has_use_ex_debugger?(tokenizer, __CALLER__.module) do
      Meta.debug(tokenizer, tokenizer.meta_debug, tokenizer.def_name, :show_tokenizer)
      Meta.debug(def_do_block_ast, tokenizer.meta_debug, tokenizer.def_name, :show_ast_before)

      updated_def_do_block_ast =
        def_do_block_ast
        |> case do
          [do: {:__block__, ctx, statements}] ->
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
                    type: :def_output_only,
                    line: Tokenizer.last_line(tokenizer)
                  )
              }
            ]

          [do: statement = {op = :|>, ctx, statements}] ->
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
                  type: :def_output_only,
                  line: Tokenizer.last_line(tokenizer)
                )
              }
            ]

          [do: statement] ->
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
                  type: :def_output_only,
                  line: Tokenizer.last_line(tokenizer)
                )
              }
            ]
        end

      Meta.debug(
        updated_def_do_block_ast,
        tokenizer.meta_debug,
        tokenizer.def_name,
        :show_ast_after
      )

      quote do
        Kernel.def(
          unquote(def_heading_ast),
          unquote(updated_def_do_block_ast)
        )
      end
    else
      quote do
        Kernel.def(
          unquote(def_heading_ast),
          unquote(def_do_block_ast)
        )
      end
    end
  end

  defmacro __using__(_) do
    quote do
      @external_resource Application.get_env(:ex_debugger, :debug_options_file)

      @debug Config.Reader.read!(Application.get_env(:ex_debugger, :debug_options_file))

      @global_output @debug
                     |> Keyword.get(:ex_debugger)
                     |> Keyword.get(:debug)
                     |> Keyword.get(:all)

      @default_output @debug
                      |> Keyword.get(:ex_debugger)
                      |> Keyword.get(:debug)
                      |> Keyword.get(:"#{__MODULE__}")

      @capture_medium @debug
                      |> Keyword.get(:ex_debugger)
                      |> Keyword.get(:debug)
                      |> Keyword.get(:capture)

      import Kernel, except: [def: 2]
      import ExDebugger, only: [def: 2]

      Kernel.def d(various, label, env \\ "", bindings \\ "", force_output? \\ false) do
        if @global_output || force_output? || @default_output do
          output = ExDebugger.Formatter.format(various, env, bindings, label)

          event = %{
            piped_value: various,
            label: label,
            bindings: bindings,
            env: ExDebugger.Formatter.env_to_map(env)
          }

          @capture_medium
          |> case do
            :stdout ->
              IO.puts(output)

            :repo ->
              ExDebugger.Repo.insert(event)

            :both ->
              IO.puts(output)
              ExDebugger.Repo.insert(event)
          end
        else
          IO.inspect(__MODULE__, label: :debugger_silenced)
        end

        various
      end
    end
  end
end
