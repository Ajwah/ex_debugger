defmodule ExDebugger.Manual do
  @moduledoc """
  `use ExDebugger.Manual` provides convenience macros that users can
  employ at strategic places in their code base when they feel that the
  default behaviour of `use ExDebugger` is not sufficient.

  Turning functionality on/off is managed by: #{
    Application.get_env(:ex_debugger, :debug_options_file)
  },
  similarly to `use ExDebugger`

  The following macros are provided:
  * d/2: First argument denotes the piped_value and second argument a
    specific label for the very same reason you would:
    ```elixir
    value
    |> IO.inspect(label: :some_label)
    ```
  * d/3: Same as d/2, with an extra argument to force output. This allows
    users to leave the settings under #{Application.get_env(:ex_debugger, :debug_options_file)} unmolested while
    quickly checking something.

  The benefit of these being macros is that all the strategic places in which users employ debugging statements can remain
  in place without this taking an extra toll on when they need to deploy to production. By switching off all the relevant
  settings under: #{Application.get_env(:ex_debugger, :debug_options_file)}, occurrences of these macros are compile time
  replaced by their value without any side effects.
  """

  defmacro __using__(_) do
    quote do
      @external_resource Application.get_env(:ex_debugger, :debug_options_file)

      defmacro dd(piped_value, label, force_output?) do
        ex_debugger_opts = ExDebugger.Options.extract(:manual_debug, __MODULE__)

        if ex_debugger_opts.global_output || force_output? || ex_debugger_opts.default_output do
          quote location: :keep do
            unquote(piped_value)
            |> ExDebugger.Event.new(unquote(label), binding(), __ENV__)
            |> ExDebugger.Event.cast(unquote(Macro.escape(ex_debugger_opts)).capture_medium)
          end
        else
          quote do
            IO.inspect(__MODULE__, label: :debugger_silenced)
            unquote(piped_value)
          end
        end
      end

      defmacro dd(piped_value, label) do
        dd(piped_value, label, false)
      end
    end
  end
end
