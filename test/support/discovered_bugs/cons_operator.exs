defmodule Support.DiscoveredBugs.ConsOperator do
  use CommendableComments
  @modulecomment """
  This is to address the bug that was discovered where using a `cons operator`
  within a `case expression` would cause a `CompileError` to be raised:
  `undefined function |/2`

  The issue here is that the `cons` operator is embedded within a `[]` on
  an `AST` level as well whereas `AstWalker` would always take the last
  element of a list when incorporating a `piping expression`.

  This became rather clear when putting the updated `AST` through `Macro.to_string`:
  ```elixir
  iex(4)> Macro.to_string(a) |> IO.puts
  [do: input |> case do
    1 ->
      (input | @rest) |> __MODULE__.d(:case_statement, __ENV__, binding(), false)
    i ->
      (input + 1 | @rest) |> __MODULE__.d(:case_statement, __ENV__, binding(), false)
  end |> __MODULE__.d(:def_output_only, __ENV__, binding(), false)]
  ```

  With the bug now fixed it is rather:
  ```elixir
  Macro.to_string(a) |> IO.puts
  [do: input |> case do
    1 ->
      [input | @rest] |> __MODULE__.d(:case_statement, __ENV__, binding(), false)
    i ->
      [input + 1 | @rest] |> __MODULE__.d(:case_statement, __ENV__, binding(), false)
  end |> __MODULE__.d(:def_output_only, __ENV__, binding(), false)]
  :ok
  ```
  """

  defmodule ManualCase do
    @moduledoc false
    use ExDebugger.Manual
    @rest [2, 3, 4]

    def run(input) do
      input
      |> case do
        1 -> [input | @rest] |> dd(:inspect)
        i -> [(input + 1) | @rest] |> dd(:inspect)
      end
    end
  end

  defmodule AutoCase do
    @moduledoc false
    use ExDebugger
    @rest [2, 3, 4]

    def run(input) do
      input
      |> case do
        1 -> [input | @rest]
        i -> [(input + 1) | @rest]
      end
    end
  end
end
