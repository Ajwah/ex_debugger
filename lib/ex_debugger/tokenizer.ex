defmodule ExDebugger.Tokenizer do
  @moduledoc false
  use CommendableComments

  @modulecomment """
  Ideally, as a regular user one should not need to know about this. However, as leaky abstractions tend to bite us by
  surprise; it may be important to be aware of this.

  The `AST` that we have access to compile time has a certain amount of loss of information that we need in order to
  pinpoint a correct line. These general pertain to `end` identifiers which make it very hard to pinpoint the correct
  line location that is relevant to annotate; such as:
  ```elixir
  case a do         # 1.
    :a -> case b do # 2.
      :b -> :ok     # 3.
      :c -> :error  # 4.
    end             # 5.
                    # 6.
    :b -> case c do # 7.
      :b -> :error  # 8.
      :c -> :ok     # 9.
    end             # 10.
  end               # 11.
  ```

  `ExDebugger` wants to auto-annotate any polyfurcation point. The lines needed to be annotated in this case are only the
  nested ones:
    * 3, 4 and
    * 8, 9

  However, from an algorithmic perspective it is rather difficult to determine whether or not a case expression is nested
  and that accordingly its parent can be excluded. This leads to the oversimplification of blindly applying the
  annotation for each and every branch in each and every case expression. As such, we also need to annotate branches `:a`
  and `:b` for the parent case expression above and the appropriate lines for that would thus constitute lines: 5 and 10
  respectively.

  However, the AST as received compile time excludes the various `end` identifiers making it difficult to distinguish
  between the above and for instance:
    ```elixir
  case a do         # 1.
    :a -> case b do # 2.
      :b -> :ok     # 3.
      :c -> :error  # 4.
                    # 5.
                    # 6.
                    # 7.
                    # 8.
    end             # 9.
                    # 10.
    :b -> case c do # 11.
      :b -> :error  # 12.
      :c -> :ok     # 13.
    end             # 14.
  end               # 15.
  ```
  In order to make things easier, this module tokenizes the respective file in which the module resides and scans for
  the various `end` identifiers accordingly.

  The downside of this solution is that effectively compile time we are tokenizing everything twice; once when Elixir
  starts compilation and secondly when we hijack the def-macro and tokenize again to correctly annotate the AST.

  Of course, it is not entirely impossible to solely rely on the raw `AST` as provided. Conceptually speaking, it is
  rather easy to inculcate that a current branch's ending is one less than the starting line of the next branch. I may
  explore this in the future; in this first iteration I went with a brute force solution instead.
  """

  defstruct file_name: "",
            defs: [],
            def_line: 0,
            def_name: "",
            module: :none,
            meta_debug: nil

  alias ExDebugger.Meta

  alias __MODULE__.{
    Definition,
    NestedModule,
    Repo
  }

  @doc false
  def new(caller, def_heading_ast) do
    meta_debug = Meta.new(caller.module)

    {def_name, def_line} = Definition.name_and_line(def_heading_ast)

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
      meta_debug: meta_debug
    })

    # |> IO.inspect
  end

  # Nested functions as they appear in code are abbreviated whereas the
  # module obtained from `__CALLER__.module` is a fully qualified `module`
  # name which includes the names of all its parents.
  # The current solution implemented is a bit naive and does not cover
  # all the cases but should suffice for the time being.
  @doc false
  def module_has_use_ex_debugger?(t = %__MODULE__{}, module) do
    nested_modules = t.defs.nested_modules
    ground_state = module in nested_modules

    module
    |> Module.split()
    |> Enum.reverse()
    |> Enum.reduce_while({ground_state, []}, fn
      _, {true, _} ->
        {:halt, {true}}

      e, {_, module_name_portions} ->
        module_name_portions = Module.concat([e | module_name_portions])
        result = module_name_portions in nested_modules
        {:cont, {result, [module_name_portions]}}
    end)
    |> elem(0)
  end

  @doc false
  def last_line(%__MODULE__{} = t) do
    t.defs
    |> Map.fetch!(t.def_line)
    |> Map.fetch!(:last_line)
  end

  @doc false
  def bifurcates?(%__MODULE__{} = t) do
    try do
      t.defs
      |> Map.fetch!(t.def_line)
      |> Map.fetch!(:polyfurcation_expressions)
      |> Kernel.!=(%{})
    rescue
      _ ->
        ExDebugger.Anomaly.raise(
          "Entry not found. Only known occurrence for this is when you try to `use ExDebugger` with a `defmacro __using__`.",
          :entry_not_found
        )
    end
  end

  @doc false
  def file(file) do
    file
    |> File.open!([:charlist])
    |> IO.read(:all)
    |> :elixir_tokenizer.tokenize(1, [])
    |> case do
      {:ok, _, _, _, ls} -> ls
    end
  end

  @doc false
  def nested_modules(tokens = [{:identifier, _, :defmodule} | _]) do
    {tokens, NestedModule.usage_ex_debugger(tokens)}
  end

  @doc false
  def groupify_defs({tokens, nested_modules}), do: groupify_defs(tokens, %{}, nested_modules)

  @doc false
  def groupify_defs([{:identifier, _, :defmodule} | tl], acc, nested_modules) do
    tl
    |> Definition.all()
    |> Enum.reduce(acc, fn [{:identifier, {line, _, nil}, _def_identifier} | tl], a ->
      [{:end, {last_line, _, nil}} | _] = Enum.reverse(tl)

      a
      |> Map.put(line, %{
        first_line: line,
        last_line: last_line,
        lines: tl,
        polyfurcation_expressions: polyfurcation_expressions(tl),
        sections: group_expressions(tl)
      })
      |> Map.put(:nested_modules, nested_modules)

      # |> Map.update(:def_lines, [line], fn ls -> ls ++ [line] end)
    end)
  end

  @doc false
  def groupify_defs(_, _, _), do: {:error, :no_defmodule}

  @doc false
  def polyfurcation_expressions(tokens) do
    tokens
    |> Enum.reduce(%{}, fn
      {_, {line, _, _}, :case}, a ->
        a
        |> Map.put(line, :case)
        |> Map.update(:case, [line], &(&1 ++ [line]))

      {_, {line, _, _}, :cond}, a ->
        a
        |> Map.put(line, :cond)
        |> Map.update(:cond, [line], &(&1 ++ [line]))

      {_, {line, _, _}, :if}, a ->
        a
        |> Map.put(line, :if)
        |> Map.update(:if, [line], &(&1 ++ [line]))

      _, a ->
        a
    end)
  end

  @doc false
  def group_expressions(tokens) do
    tokens
    |> Enum.reduce({[:ignore], %{}}, fn
      {:fn, _}, {stack, a} ->
        {[:ignore_block_till_end | stack], a}

      e = {_, {line, _, _}, :case}, {stack, a} ->
        {[{:groupify_defs, line} | stack], Map.put(a, line, [e])}

      e = {_, {line, _, _}, :if}, {stack, a} ->
        {[{:groupify_defs, line} | stack], Map.put(a, line, [e])}

      e = {_, {line, _, _}, :cond}, {stack, a} ->
        {[{:groupify_defs, line} | stack], Map.put(a, line, [e])}

      e = {:end, {line, _, _}}, {stack = [last_block | tl], a} ->
        last_block
        |> case do
          :ignore ->
            {stack, Map.put(a, :end, line)}

          :ignore_block_till_end ->
            {tl, a}

          {:groupify_defs, line} ->
            {tl, Map.update(a, line, [e], fn ls -> handle_sections(ls ++ [e]) end)}
        end

      e, {stack = [last_block | _], a} ->
        last_block
        |> case do
          :ignore -> {stack, a}
          :ignore_block_till_end -> {stack, a}
          {:groupify_defs, line} -> {stack, Map.update(a, line, [e], fn ls -> ls ++ [e] end)}
        end
    end)
    |> elem(1)
  end

  @doc false
  def handle_sections(block = [{_, {_line, _, _}, _op} | _]) do
    block
    |> Enum.reverse()
    |> Enum.reduce({nil, []}, fn
      {:end, {line, _, _}}, {nil, []} ->
        {{:end_section, line - 1}, []}

      {_, {line, _, _}, :if}, {{:end_section, end_section}, a} ->
        {{:end_section, line - 1}, [%{start_section: line, end_section: end_section} | a]}

      {_, {line, _, _}, :else}, {{:end_section, end_section}, a} ->
        {{:end_section, line - 1}, [%{start_section: line, end_section: end_section} | a]}

      {_, {line, _, _}, :->}, {{:end_section, end_section}, a} ->
        {{:end_section, line - 1}, [%{start_section: line, end_section: end_section} | a]}

      _, acc ->
        acc
    end)
    |> elem(1)
  end
end
