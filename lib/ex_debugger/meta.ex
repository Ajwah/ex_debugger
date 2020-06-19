defmodule ExDebugger.Meta do
  @moduledoc """
  Debugging the debugger.
  In order to facilitate development of `ExDebugger`, various `inspect`
  statements have been placed strategically which can be switched on/off
  by means of the settings under `debug_options.exs`.

  The `struct` defined here validates the input received therefrom and
  provides a set of convenience functions to abstract the code away from
  'ugly' conditional statements.
  """
  @opts ExDebugger.Formatter.opts()

  @external_resource Application.get_env(:ex_debugger, :debug_options_file)
  @debug Config.Reader.read!(Application.get_env(:ex_debugger, :debug_options_file))

  @accepted_keys MapSet.new([:show_module_tokens, :show_tokenizer, :show_ast_before, :show_ast_after])
  @default %{show_module_tokens: false, show_tokenizer: false, show_ast_before: false, show_ast_after: false}

  defstruct [
    all: @default,
    caller: @default,
    caller_module: nil
  ]

  def new(caller_module) do
    meta_debug = Keyword.get(@debug, :ex_debugger) |> Keyword.get(:meta_debug)
    all = meta_debug
      |> Keyword.get(:all)
      |> validate_meta_debug

    caller = meta_debug
      |> Keyword.get(caller_module, @default)
      |> validate_meta_debug


    struct!(__MODULE__, %{
      all: all,
      caller: caller,
      caller_module: caller_module
    })
  end

  def debug(input, meta = %__MODULE__{}, def_name, key) do
    if Map.get(meta.all, key) || Map.get(meta.caller, key) do
      IO.inspect(input, [{:label, format_label(meta.caller_module, def_name, key)} | @opts])
    end
    input
  end

  defp format_label(caller_module, def_name, key) do
    "#{caller_module}/#{def_name}/#{format_key(key)}"
  end

  defp format_key(:show_module_tokens), do: "caller_module"
  defp format_key(:show_tokenizer), do: "tokenizer"
  defp format_key(:show_ast_before), do: "def_do_block_ast"
  defp format_key(:show_ast_after), do: "updated_def_do_block_ast"

  defp validate_meta_debug(input) do
    input
    |> case do
      m when is_map(m) -> if MapSet.new(current_keys = Map.keys(m)) == @accepted_keys do
          m
        else
          raise "#{@external_resource} section: :meta_debug contains incorrect configuration. Accepted Keys: #{inspect(@accepted_keys, @opts)}. Instead: #{inspect(current_keys, @opts)}"
        end
      {a, b, c, d} -> %{show_module_tokens: a, show_tokenizer: b, show_ast_before: c, show_ast_after: d}
      incorrect_format -> raise "#{@external_resource} section: :meta_debug contains incorrect configuration. Either specify a map with keys: #{inspect(@accepted_keys, @opts)}. Either specify a tuple; for example: {false, true, false, false}. Instead: #{inspect(incorrect_format, @opts)}"
    end
  end

end
