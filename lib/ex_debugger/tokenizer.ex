defmodule ExDebugger.Tokenizer do
  @moduledoc false

  defstruct [
    file_name: "",
    defs: [],
    def_line: 0,
    def_name: "",
    module: :none,
    meta_debug: nil
    # def_lines: []
  ]


  alias ExDebugger.Meta
  alias __MODULE__.{
    Definition,
    NestedModule,
    Repo,
  }

  # defmacro __using__(_) do
  #   quote do
  #     __ENV__.file
  #     |> ExDebugger.Tokenizer.file
  #     |> ExDebugger.Tokenizer.groupify_defs
  #     |> IO.inspect([{:label, __MODULE__} | ExDebugger.Formatter.opts()])
  #   end
  # end

  def new(caller, fn_call_ast) do
    meta_debug = Meta.new(caller.module)
    {def_name, [line: def_line], _} = fn_call_ast

    file_name = caller.file
    if Repo.is_uninitialized?(file_name) do
      file_name
      |> file
      |> Meta.debug(meta_debug, "", :show_module_tokens)
      |> nested_modules
      |> groupify_defs
      |> Repo.insert(file_name)
    end

    defs = Repo.lookup(file_name)

    struct!(__MODULE__, %{
      file_name: file_name,
      def_line: def_line,
      def_name: def_name,
      defs: defs,
      # def_lines: defs.def_lines,
      module: caller.module,
      meta_debug: meta_debug,
    })
    # |> IO.inspect
  end

  # Nested functions as they appear in code are abbreviated whereas the
  # module obtained from `__CALLER__.module` is a fully qualified `module`
  # name which includes the names of all its parents.
  # The current solution implemented is a bit naive and does not cover
  # all the cases but should suffice for the time being.
  def module_has_use_ex_debugger?(t = %__MODULE__{}, module) do
    nested_modules = t.defs.nested_modules
    ground_state = module in nested_modules

    module
    |> Module.split
    |> Enum.reverse
    |> Enum.reduce_while({ground_state, []}, fn
      _, {true, _} -> {:halt, {true}}
      e, {_, module_name_portions} ->
        module_name_portions = Module.concat([e | module_name_portions])
        result = module_name_portions in nested_modules
        {:cont, {result, [module_name_portions]}}
    end)
    |> elem(0)
  end

  def last_line(%__MODULE__{} = t) do
    t.defs
    |> Map.fetch!(t.def_line)
    |> Map.fetch!(:last_line)
  end

  def bifurcates?(%__MODULE__{} = t) do
    t.defs
    |> Map.fetch!(t.def_line)
    |> Map.fetch!(:bifurcation_expressions)
    |> Kernel.!=(%{})
  end

  def file(file) do
    file
    |> File.open!([:charlist])
    |> IO.read(:all)
    |> :elixir_tokenizer.tokenize(1, [])
    |> elem(1)
  end

  def nested_modules(tokens = [{:identifier, _, :defmodule} | _]) do
    {tokens, NestedModule.usage_ex_debugger(tokens)}
  end

  def groupify_defs({tokens, nested_modules}), do: groupify_defs(tokens, %{}, nested_modules)
  def groupify_defs([{:identifier, _, :defmodule} | tl], acc, nested_modules) do
    tl
    |> Definition.all
    |> Enum.reduce(acc, fn [{:identifier, {line, _, nil}, :def} | tl], a ->
      [{:end, {last_line, _, nil}} | _] = Enum.reverse(tl)
      a
      |> Map.put(line, %{
        first_line: line,
        last_line: last_line - 1,
        # lines: tl,
        bifurcation_expressions: bifurcation_expressions(tl),
        sections: group_expressions(tl)

      })
      |> Map.put(:nested_modules, nested_modules)
      # |> Map.update(:def_lines, [line], fn ls -> ls ++ [line] end)
    end)
  end
  def groupify_defs(_, _, _), do: {:error, :no_defmodule}

  def bifurcation_expressions(tokens) do
    tokens
    |> Enum.reduce(%{}, fn
      {_, {line, _, _}, :case}, a -> a
        |> Map.put(line, :case)
        |> Map.update(:case, [line], &(&1 ++ [line]))
      {_, {line, _, _}, :cond}, a -> a
        |> Map.put(line, :cond)
        |> Map.update(:cond, [line], &(&1 ++ [line]))
      {_, {line, _, _}, :if}, a -> a
        |> Map.put(line, :if)
        |> Map.update(:if, [line], &(&1 ++ [line]))
      _, a -> a
    end)
  end

  def group_expressions(tokens) do
    tokens
    |> Enum.reduce({[:ignore], %{}}, fn
      {:fn, _}, {stack, a} -> {[:ignore_block_till_end | stack], a}
      e = {_, {line, _, _}, :case}, {stack, a} -> {[{:groupify_defs, line} | stack], Map.put(a, line, [e])}
      e = {_, {line, _, _}, :if}, {stack, a} -> {[{:groupify_defs, line} | stack], Map.put(a, line, [e])}
      e = {_, {line, _, _}, :cond}, {stack, a} -> {[{:groupify_defs, line} | stack], Map.put(a, line, [e])}
      e = {:end, {line, _, _}}, {stack = [last_block | tl], a} -> last_block
        |> case do
          :ignore -> {stack, Map.put(a, :end, line)}
          :ignore_block_till_end -> {tl, a}
          {:groupify_defs, line} -> {tl, Map.update(a, line, [e], fn ls -> handle_sections(ls ++ [e]) end)}
        end

        e, {stack = [last_block | _], a} -> last_block
        |> case do
          :ignore -> {stack, a}
          :ignore_block_till_end -> {stack, a}
          {:groupify_defs, line} -> {stack, Map.update(a, line, [e], fn ls -> ls ++ [e] end)}
        end
    end)
    |> elem(1)
  end

  def handle_sections(block = [{_, {_line, _, _}, _op} | _]) do
    block
    |> Enum.reverse
    |> Enum.reduce({nil, []}, fn
      {:end, {line, _, _}}, {nil, []} -> {{:end_section, line - 1}, []}
      {_, {line, _, _}, :if}, {{:end_section, end_section}, a} -> {{:end_section, line - 1}, [%{start_section: line, end_section: end_section} | a]}
      {_, {line, _, _}, :else}, {{:end_section, end_section}, a} -> {{:end_section, line - 1}, [%{start_section: line, end_section: end_section} | a]}
      {_, {line, _, _}, :->}, {{:end_section, end_section}, a} -> {{:end_section, line - 1}, [%{start_section: line, end_section: end_section} | a]}
      _, acc -> acc
    end)
    |> elem(1)
    # |> Map.put(:block, %{type: op, line: line, raw: block})
  end
end
