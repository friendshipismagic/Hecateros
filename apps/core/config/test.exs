use Mix.Config

config :core, Core.Repo,
  adapter: Sqlite.Ecto2,
  database: "priv/test.sqlite3",
  pool: Ecto.Adapters.SQL.Sandbox
