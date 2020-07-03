defmodule HelloWorld do
  use ExDebugger.Manual

  def hello(input) do
    if input == :world do
      "Hello World!" |> dd(:investigation, true)
    else
      "Hello Something Else: #{input}"
    end
  end
end
