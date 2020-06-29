defmodule ExDebugger.Tokenizer.NestedModule do
  @moduledoc false

  # def nested_module(tokens) do
  #   tokens
  #   |> Enum.drop_while(fn
  #     {:identifier, _, :defmodule} -> false
  #     _ -> true
  #   end)
  #   |> name
  # end

  def usage_ex_debugger(tokens) do
    usage_ex_debugger(tokens, %{ls: [], module_name: nil})
  end

  def usage_ex_debugger([{:identifier, _, :defmodule} | tl], acc) do
    {module_name, remainder} = name(tl)
    usage_ex_debugger(remainder, %{module_name: module_name, ls: acc.ls})
  end

  def usage_ex_debugger([{:identifier, _, :use}, {:alias, _, :ExDebugger} | tl], acc) do
    usage_ex_debugger(tl, %{module_name: nil, ls: [acc.module_name | acc.ls]})
  end

  def usage_ex_debugger([_ | tl], acc), do: usage_ex_debugger(tl, acc)
  def usage_ex_debugger([], %{ls: ls}), do: ls

  # ) do

  #     tokens
  #     |> Enum.drop_while(fn
  #       {:identifier, {3, 3, nil}, :use},
  #       {:identifier, _, :defmodule} -> false
  #       _ -> true
  #     end)
  #   end

  def name(ls) when is_list(ls) do
    {acc, tl} = name(ls, [])

    {
      acc
      |> Enum.reverse()
      |> Module.concat(),
      tl
    }
  end

  defp name([{:alias, _, name_portion} | tl], acc), do: name(tl, [name_portion | acc])
  defp name([{:., _} | tl], acc), do: name(tl, acc)
  defp name([{:do, _} | tl], acc), do: {acc, tl}
end
