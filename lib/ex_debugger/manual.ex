defmodule ExDebugger.Manual do
  @moduledoc """
  `use` `ExDebugger.Manual` provides convenience macros that users can
  employ at strategic places in their code base when they feel that the
  default behaviour of `use ExDebugger` is not sufficient.

  Turning functionality on/off is managed by: `#{Documentation.debug_options_path()}`,
  similarly to `use ExDebugger`

  The following macros are provided:
  * `dd/2`: First argument denotes the piped_value and second argument a
    specific label for the very same reason you would:
    ```elixir
    value
    |> IO.inspect(label: :some_label)
    ```
  * `dd/3`: Same as `dd/2`, with an extra argument to force output. This allows
    users to leave the settings under `#{Documentation.debug_options_path()}` unmolested while
    quickly checking something.

  The benefit of these being macros is that all the strategic places in which users employ debugging statements can remain
  in place without this taking an extra toll on when they need to deploy to production. By switching off all the relevant
  settings under: `#{Documentation.debug_options_path()}`, occurrences of these macros are compile time
  replaced by their value without any side effects.
  """

  def __dd__(piped_value, label, module, force_output?) do
    ex_debugger_opts = ExDebugger.Options.extract(:manual_debug, module)

    if ex_debugger_opts == :no_debug_options_file_set do
      quote do
        unquote(piped_value)
      end
    else
      if ex_debugger_opts.global_output || force_output? || ex_debugger_opts.default_output do
        quote location: :keep do
          unquote(piped_value)
          |> ExDebugger.Event.new(unquote(label), binding(), __ENV__)
          |> ExDebugger.Event.cast(unquote(Macro.escape(ex_debugger_opts)).capture_medium,
            warn: unquote(Macro.escape(ex_debugger_opts)).warn
          )
        end
      else
        if ex_debugger_opts.warn do
          quote do
            Logger.warn("Manual Debugger output silenced for: #{__MODULE__}")
            unquote(piped_value)
          end
        else
          quote do
            unquote(piped_value)
          end
        end
      end
    end
  end

  defmacro __using__(_) do
    quote location: :keep do
      if Application.get_env(:ex_debugger, :debug_options_file) do
        @external_resource Application.get_env(:ex_debugger, :debug_options_file)
        require Logger
      end

      @spec dd(any(), atom(), boolean()) :: any()
      @doc false
      defmacro dd(piped_value, label, force_output?) do
        ExDebugger.Manual.__dd__(piped_value, label, __MODULE__, force_output?)
      end

      @spec dd(any(), atom()) :: any()
      @doc false
      defmacro dd(piped_value, label) do
        ExDebugger.Manual.__dd__(piped_value, label, __MODULE__, false)
      end

      @spec dd(atom()) :: any()
      @doc false
      defmacro dd(label) do
        ExDebugger.Manual.__dd__(nil, label, __MODULE__, false)
      end

      @spec dd :: any()
      @doc false
      defmacro dd do
        ExDebugger.Manual.__dd__(nil, nil, __MODULE__, false)
      end
    end
  end
end
