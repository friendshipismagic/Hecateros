defmodule IRC.Mixfile do
  use Mix.Project

  def project do
    [
      app: :irc,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {IRC.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:core, in_umbrella: true},
      {:web,  in_umbrella: true},
      {:exirc, github: "bitwalker/exirc", branch: "master"},
      {:gen_stage, "~> 0.12.2"},
    ]
  end
end
