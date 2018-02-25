use Mix.Config

config :core, Core.Repo,
  adapter: Sqlite.Ecto2,
  database: "${DATABASE_PATH}"
