# ExDebugger

Auto-annotates `AST` at various strategic places with debugging
expressions to allow for fast iteration of debugging during development
time.

## Raison d'être
There are multiple ways of debugging an `Elixir` application:
  1. `IO.puts`/`IO.inspect`/`Logger`
  2. `IEx.pry`
  3. `:debugger` as explained [here](https://elixir-lang.org/getting-started/debugging.html#debugger) and [here](https://elixirschool.com/en/lessons/specifics/debugging/#debugging). There is also [a VSCode plugin](https://github.com/elixir-lsp/vscode-elixir-ls) that automates the experience if you can get it to working. Likewise for [emacs](https://github.com/emacs-lsp/dap-mode) and for those who use [IntelliJ Elixir](https://github.com/KronicDeth/intellij-elixir#debugger)
  4. Instrumenting:
     * [ex_ray](https://github.com/derailed/ex_ray)
  5. Tracing:
     * [rexbug](https://github.com/nietaki/rexbug)
     * [exrun](https://github.com/liveforeverx/exrun)
     * [dbg](https://github.com/fishcakez/dbg)
     * [tracer](https://github.com/gabiz/tracer)
     * [erlyberly](https://github.com/andytill/erlyberly)

In my personal practice of doing `TDD` and getting to the bottom of a particular bug the above options are lacking:
  * The first two are attractive to use for their simplicity but it becomes quickly tiresome
  having to keep annotating the codebase with certain of these expressions, remove them/comment them out only to put them back in at the same spot at a later time to explore another shortcomming. And after all your fine due diligence: “Oh no! I accidently merged in a commented out `IO.inspect` into master!”
  * Option 3, to set up manually introduces a great amount of overhead and the `VSCode plugin` never worked for me out of the box. Next, in my `TDD` flow,
  I just want to `mix test some_file_test.exs:34` and get on with my life.
  * Option 4 and 5 seem attractive to me in terms of debugging something running in
  production when you are interested in flamegraphs and graphs for process memory usage or tracing of messages etc. These are tools for highly specialized use. Some of them support detailed call sequences but at the expense of involving everything from A to Z; including the standard library. This is not entirely helpful when your aim is to go from red to green in your `TDD`-flow.
  Some allow you to trace a specific module, or even a specific function which is great when all your functions are one-liners. When they are not you may be interested in understanding how state is changing within the functions and the main places where that should matter is where polyfurcation occurs with `if`, `case`, `cond` and/or anonymous function case headings which is not supported out of the box.
  On top of that is that running some of these tools may require you to have a separate node running on `epmd` that needs to connect to your application and thus may pose an increased indirection over you running a simple `mix test some_file_test.exs:34`.
  Most certainly there is value in becoming versatile in these tools by using them in your development as a practice. But if your primary concern is that of your daily bread-and-butter-`TDD`-flow; then these tools are rather overkill, especially for the junior audience.

In all the above cases, the main stumbling block on my part can be best summarized as that none of them are particularly fun to use in the context of a `TDD`-flow or quickly hacking something together. Debugging requires a certain focus and the shorter you can make the feedback loop the better.

As an experiment, I authored this library with the aim of shortening this feedback loop while keeping ceremony to a bear minimum and thus it seeks to:
  1. Be so simple it is accessible to every developer regardless as to their seniority level/experience. e.g.:
     1. All the obvious places in which change of state can occur are being annotated with hidden debugging statements to minimize clutter. These are:
        1. At the beginning of every `def`/`defp`
        2. At the end of every `def`/`defp`
        3. At every juncture inside every polyfurcating expression, e.g.:
           * `case`
           * `if/else`
           * `cond`
     2. All the hidden debugging expressions can be toggled on or off; allowing you to differentiate between development and production. As such:
        * you can selectively turn on/off places in your code base that are relevant to your `TDD`-flow and avoid clutter in the output you need to introspect
        * these hidden statements will not pose any additional overhead when running in production thus effectively allowing you to keep your entire code base intact. No more: “Oh, I merged in that commented-out `IO.inspect` into master”-type of nonsense.
  2. Be versatile so that it can accommodate finer granularity by giving you access to a `macro` that allows you to manually annotate alternative places in your code base while giving you access to the same benefits as enumerated under point 1 above.

I am personally using this in my projects to see how the flow works out from a practical stand point which may make me introduce extra features or potentially put a full halt to this project altogether. In the duration of this beta release, kindly feel free to experiment accordingly. Feedback is welcome.

## Installation

```elixir
def deps do
  [
    {:ex_debugger, "~> 0.1.2"}
  ]
end
```

## Usage
`config.exs`:

```elixir
import Config

config :ex_debugger, :debug_options_file, "#{File.cwd!()}/debug_options.exs"
```

`debug_options.exs`:

```elixir
config :ex_debugger, :debug,
  capture: :stdout, #[:repo, :stdout, :both, :none]
  warn: false,
  all: false,
  "Elixir.HelloWorld": true
```

For auto-annotating your `module` with debugging statements:

`hello_world.exs`:

```elixir
defmodule HelloWorld do
  use ExDebugger

  def hello(input) do
    if input == :world do
      "Hello World!"
    else
      "Hello Something Else: #{input}"
    end
  end
end
```

Effectively, this will manipulate the `AST` to look like this behind the scenes:
```elixir
defmodule HelloWorld do
  use ExDebugger

  def hello(input) do
    if input == :world do
      "Hello World!" |> d(:if_statement, __ENV__, binding(), false)
    else
      "Hello Something Else: #{input}" |> d(:if_statement, __ENV__, binding(), false)
    end
    |> d(:def_output, __ENV__, binding(), false)
  end
end
```
Kindly consult the resources on [__ENV__](https://hexdocs.pm/elixir/Macro.Env.html) and [binding()](https://hexdocs.pm/elixir/Kernel.html#binding/1) to appreciate the value they provide.

When running the following:
```elixir
iex(1)> c("hello_world.exs")
iex(2)> HelloWorld.hello(:world)
```

you will see:
```elixir
===================:if_statement======================
Piped Value: "Hello World!"
Bindings: [input: :world]

file: path_to_your_project/hello_world.exs:6
module: Elixir.HelloWorld
function: "&hello/1"

=============================================

===================:def_output_only======================
Piped Value: "Hello World!"
Bindings: [input: :world]

file: path_to_your_project/hello_world.exs:10
module: Elixir.HelloWorld
function: "&hello/1"

=============================================
```
This of course provided you have made the appropriate settings under `debug_options.exs`
as depicted above.


In the case you need extra fine granularity then you can opt to do:
```elixir
defmodule A do
  use ExDebugger.Manual
end
```
which will give you access to the macro `dd\2,3` that can be used as follows:

```elixir
defmodule HelloWorld do
  use ExDebugger.Manual

  def hello(input) do
    if input == :world do
      "Hello World!" |> dd(:investigation)
    else
      "Hello Something Else: #{input}"
    end
  end
end
```
This renders the following output:

```elixir
iex(1)> c("hello_world.exs")
iex(2)> HelloWorld.hello(:world)
===================:investigation======================
Piped Value: "Hello World!"
Bindings: [input: :world]

file: path_to_project/hello_world.exs:6
module: Elixir.HelloWorld
function: "&hello/1"

=============================================

"Hello World!"
```

For manual debug, you need to configure `debug_options.exs` as follows:
```elixir
config :ex_debugger, :manual_debug,
  capture: :stdout, #[:repo, :stdout, :both, :none]
  warn: false,
  all: false,
  "Elixir.HelloWorld": true
```

Both `use ExDebugger` and `use ExDebugger.Manual` can be used in tandem if need be.

## Limitations
All usage is supported except for certain cases of `defmacro __using__(_)`.
Currently, the test scenarios involving `defmacro __using__(_)` have been
forced to pass for the time being. If someone deeply cares about this, then
feel free to submit advice/PR accordingly.

## RoadMap
In the case that this library has good working potential, then the following are the features I would like to see implemented:

1. Auto annotation of anonymous function cases and support for `unless`
2. VSCode Extension:
   * Leveraging the persisted `Debugging Events` in ones project, walk through the code base while depicting change of state as a normal IDE debugger.
   * Allow for annotation of these persisted `Debugging Events` with comments to document certain observations.
   * Enable/Disable in the walk-through view certain `Debugging Events` by means of filters to eliminate clutter and/or to retain the essential subset that demonstrates the bug.
   * Persist this subset somehow for future replay purposes either in VSCode or either as a GIF. This
   may facilitate in communicating certain mistakes in the code base in one's PR or issue tracker.


## Contributing
In case you see potential in this library and would like to contribute then feel free to reach out.

[docs](https://hexdocs.pm/ex_debugger)
