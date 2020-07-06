defmodule ExDebugger.MixProject do
  use Mix.Project

  @version "0.1.1"
  @github "https://github.com/Ajwah/ex_debugger"
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
        main: "ExDebugger",
        extras: ["README.md"]
      ],
      aliases: [docs: &build_docs/1],
      version: @version,
      elixir: "~> 1.10",
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

    args = ["ExDebugger", @version, Mix.Project.compile_path()]
    opts = ~w[--main ExDebugger --source-ref v#{@version} --source-url #{@github}]
    System.cmd(ex_doc, args ++ opts)
    Mix.shell().info("Docs built successfully")
  end
end
