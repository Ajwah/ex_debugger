defmodule ExDebugger.Tokenizer.NestedModule do
  @moduledoc false
  use CommendableComments

  @modulecomment """
  Nested Modules require special attention when employing `use ExDebugger`. This is because by default, every module
  imports `Kernel` which includes `def` and `defp` which in the interest of hijacking the same requires `use ExDebugger`
  to import selectively:
  ```
    import Kernel, except: [def: 2, defp: 2]
    import ExDebugger, only: [def: 2, defp: 2]
  ```

  `import` is lexcially scoped, which means that accordingly, every nested module will import the functionality as done
  by the parent module. For example the following works:
  ```elixir
  defmodule A do
    def a, do: 1
  end

  defmodule B do
    import A
    def b, do: a()
    defmodule C do
      def c, do: a()
    end
  end
  iex(_)> B.C.c
  1
  ```

  This means that automatically each nested module would import the modified macros from `ExDebugger` and end up
  crashing as `d/5` is not incorporated in their module definitions(as opposed to the parent module because `use` is not
  lexically scoped).

  It is not sensible to fix this crashing by automatically incorporating `d/5` in the nested modules as well as a
  `use ExDebugger` on a parent module level having effect on the nested modules occurring therein is too implicit of
  behaviour. As such, in order to maintain the existing convenience without crashing stuff this module has been coined
  to collect all nested modules that explicitly employ `use ExDebugger` so we can detect whether or not definitions in a
  nested module need to be annotated or not.
  """

  @doc false
  def usage_ex_debugger(tokens) do
    usage_ex_debugger(tokens, %{ls: [], module_name: nil})
  end

  @doc false
  def usage_ex_debugger([{:identifier, _, :defmodule} | tl], acc) do
    {module_name, remainder} = name(tl)
    usage_ex_debugger(remainder, %{module_name: module_name, ls: acc.ls})
  end

  def usage_ex_debugger([{:identifier, _, :use}, {:alias, _, :ExDebugger} | tl], acc) do
    usage_ex_debugger(tl, %{module_name: nil, ls: [acc.module_name | acc.ls]})
  end

  def usage_ex_debugger([_ | tl], acc), do: usage_ex_debugger(tl, acc)
  def usage_ex_debugger([], %{ls: ls}), do: ls

  @doc false
  def name(ls) when is_list(ls) do
    {acc, tl} = name(ls, [])

    {
      acc
      |> Enum.reverse()
      |> Module.concat(),
      tl
    }
  end

  @doc false
  defp name([{:alias, _, name_portion} | tl], acc), do: name(tl, [name_portion | acc])
  defp name([{:., _} | tl], acc), do: name(tl, acc)
  defp name([{:do, _} | tl], acc), do: {acc, tl}
end
