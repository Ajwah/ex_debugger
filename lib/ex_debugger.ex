defmodule ExDebugger do
  @moduledoc """
  Usage: `use ExDebugger`

  This effectively hijacks macros `def` and `defp` to auto-annotate the `AST` they receive compile time with strategically
  placed debugging expressions where they generate debugging events:
    1. At the end of every `def`/`defp`
    2. At every juncture in every bifurcation expression which are:
      * case
      * cond
      * if
      * TODO:
        * unless
        * Case Arrows of Anonymous Functions

  The various debugging events that get generated from such automated annotations should allow a developer to fully
  introspect from beginning till end a particular traversal of the code path while having all the relevant
  information available to understand how state changes accordingly. In the cases where more granularity is required,
  one can always resort to the convenience of `use ExDebugger.Manual` which is explained therein accordingly.

  This behaviour of annotating `AST` compile time in such an invasive and aggressive manner can be toggled in the debug
  options file: #{Application.get_env(:ex_debugger, :debug_options_file)}. This should facilitate regulating the granularity in which
  debug events are generated during development without the headache of having to eliminate `use ExDebugger` from every
  module when merging into `master` and deploying to production.
  """

  defmacro def(def_heading_ast, def_do_block_ast \\ nil) do
    ExDebugger.Helpers.Def.annotate(:def, __CALLER__, def_heading_ast, def_do_block_ast)
  end

  defmacro defp(def_heading_ast, def_do_block_ast \\ nil) do
    ExDebugger.Helpers.Def.annotate(:defp, __CALLER__, def_heading_ast, def_do_block_ast)
  end

  defmodule Options do
    @moduledoc """
    Responsible for extracting and validating the various options that users provide to toggle debugging concerns in the
    debug options file: #{Application.get_env(:ex_debugger, :debug_options_file)}.
    """
    defstruct [
      :global_output,
      :default_output,
      :capture_medium
    ]

    @external_resource Application.get_env(:ex_debugger, :debug_options_file)
    @options Config.Reader.read!(Application.get_env(:ex_debugger, :debug_options_file))
    @valid_capture_options [:repo, :stdout, :both]

    def extract(type, module) do
      with {_, true} <- {:list_check, is_list(@options)},
           {_, ex_debugger} <- {:retrieval, Keyword.get(@options, :ex_debugger)},
           {_, true} <- {{:ex_debugger, ex_debugger}, is_list(ex_debugger)},
           {_, options} <- {:retrieval, Keyword.get(ex_debugger, type)},
           {_, true} <- {{type, ex_debugger, options}, is_list(options)} do
        struct(__MODULE__, %{
          global_output: options |> Keyword.get(:all),
          default_output: options |> Keyword.get(:"#{module}"),
          capture_medium: capture_medium(type, options)
        })
      else
        {_stage, false} ->
          do_raise("Missing Configuration", type, :missing_configuration)
      end
    end

    defp do_raise(heading, type, label) do
      ExDebugger.Anomaly.raise(
        """
        #{heading}
        Kindly double check #{@external_resource} that it encompasses:
        ```elixir
          config :ex_debugger, :#{type},
            capture: :repo, ##{inspect(@valid_capture_options)}
            all: false,
            "Elixir.SomeModule": true # Take note of prepending "Elixir." here in front of the modules you are debugging
        ```
        """,
        label
      )
    end

    defp capture_medium(type, options) do
      if (capture_option = Keyword.get(options, :capture)) in @valid_capture_options do
        capture_option
      else
        capture_option
        |> case do
          nil ->
            do_raise("Missing Capture Configuration", type, :missing_capture_configuration)

          anomaly ->
            do_raise(
              "Incorrect Capture Configuration\nThe value provided: #{anomaly} is incorrect.",
              type,
              :incorrect_capture_configuration
            )
        end
      end
    end
  end

  defmacro __using__(_) do
    quote do
      @external_resource Application.get_env(:ex_debugger, :debug_options_file)
      @ex_debugger_opts ExDebugger.Options.extract(:debug, __MODULE__)

      import Kernel, except: [def: 2, defp: 2]
      import ExDebugger, only: [def: 2, defp: 2]

      Kernel.def d(piped_value, label, env, bindings, force_output?) do
        if @ex_debugger_opts.global_output || force_output? || @ex_debugger_opts.default_output do
          piped_value
          |> ExDebugger.Event.new(label, bindings, env)
          |> ExDebugger.Event.cast(@ex_debugger_opts.capture_medium)
        else
          IO.inspect(__MODULE__, label: :debugger_silenced)
        end

        piped_value
      end
    end
  end
end
