use Mix.Config

config :core, Core.Repo,
  adapter: Sqlite.Ecto2,
  database: "priv/prod.sqlite3"
