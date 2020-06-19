defmodule ExDebugger.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_debugger,
      version: "0.1.0",
      elixir: "~> 1.10",
      # build_path: "../../_build",
      # deps_path: "../../deps",
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
    []
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
