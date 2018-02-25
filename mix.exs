defmodule Hecateros.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env == :prod,
      aliases: aliases()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.

  defp aliases do
    [
      "ecto.setup": ["ecto.create -r Core.Repo", "ecto.migrate -r Core.Repo", "run apps/core/priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop -r Core.Repo", "ecto.setup"],
      "test": ["ecto.create --quiet -r Core.Repo", "ecto.migrate -r Core.Repo", "test"]
    ]
  end
end
