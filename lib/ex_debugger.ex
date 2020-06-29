defmodule ExDebugger do
  @moduledoc false

  defmacro def(def_heading_ast, def_do_block_ast \\ nil) do
    ExDebugger.Def.annotate(:def, __CALLER__, def_heading_ast, def_do_block_ast)
  end

  defmacro defp(def_heading_ast, def_do_block_ast \\ nil) do
    ExDebugger.Def.annotate(:defp, __CALLER__, def_heading_ast, def_do_block_ast)
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

      import Kernel, except: [def: 2, defp: 2]
      import ExDebugger, only: [def: 2, defp: 2]

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
