use Mix.Config

config :core, Core.Repo,
  adapter: Sqlite.Ecto2,
  database: "${DATABASE_PATH}",
  loggers: [Core.RepoInstrumenter] # and maybe Ecto.LogEntry? Up to you

config :prometheus, Web.PhoenixInstrumenter,
  controller_call_labels: [:controller, :action],
  duration_buckets: [10, 25, 50, 100, 250, 500, 1000, 2500, 5000,
                     10_000, 25_000, 50_000, 100_000, 250_000, 500_000,
                     1_000_000, 2_500_000, 5_000_000, 10_000_000],
  registry: :default,
  duration_unit: :milliseconds


config :prometheus, Web.PipelineInstrumenter,
  labels: [:status_class, :method, :host, :scheme, :request_path],
  duration_buckets: [10, 100, 1_000, 10_000, 100_000,
					 300_000, 500_000, 750_000, 1_000_000,
					 1_500_000, 2_000_000, 3_000_000],
  registry: :default,
  duration_unit: :milliseconds

