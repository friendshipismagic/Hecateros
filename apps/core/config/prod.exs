use Mix.Config

config :core, Core.Repo,
  adapter: Sqlite.Ecto2,
  database: "prod.sqlite3"
