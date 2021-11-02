defmodule ExDebugger.MixProject do
  use Mix.Project

  @vsn "0.1.5"
  @github "https://github.com/Ajwah/ex_debugger"
  @name "ExDebugger"

  def project do
    [
      app: :ex_debugger,
      description: "Facilitate debugging by auto-annotating your code-base",
      package: %{
        licenses: ["Apache-2.0"],
        source_url: @github,
        links: %{"GitHub" => @github}
      },
      docs: [
        main: @name,
        extras: ["README.md"]
      ],
      aliases: [docs: &build_docs/1],
      version: @vsn,
      elixir: "~> 1.13.0-rc.0",
      config_path: "config/config.exs",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:commendable_comments, "~> 0.1.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp build_docs(_) do
    Mix.Task.run("compile")
    ex_doc = Path.join(Mix.path_for(:escripts), "ex_doc")

    unless File.exists?(ex_doc) do
      raise "cannot build docs because escript for ex_doc is not installed"
    end

    args = [@name, @vsn, Mix.Project.compile_path()]
    opts = ~w[--main #{@name} --source-ref v#{@vsn} --source-url #{@github}]
    System.cmd(ex_doc, args ++ opts)
    Mix.shell().info("Docs built successfully")
  end
end
