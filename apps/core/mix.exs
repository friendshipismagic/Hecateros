defmodule Core.Mixfile do
  use Mix.Project

  def project do
    [
      app: :core,
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
      extra_applications: [:logger, :hackney],
      mod: {Core.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:distillery, "~> 1.5"},
      {:ecto, "~> 2.2"},
      {:exirc, github: "bitwalker/exirc"},
      {:hashids, "~> 2.0"},
      {:prometheus_ecto, "~> 1.0"},
      {:prometheus_ex, "~> 1.1"},
      {:prometheus_phoenix, "~> 1.2"},
      {:prometheus_plugs, "~> 1.1"},
      {:prometheus_process_collector, "~> 1.3"},
      {:sqlite_ecto2, "~> 2.2"},
      {:tesla, "~> 0.10"}
    ]
  end
end
