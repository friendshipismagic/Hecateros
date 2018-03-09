defmodule Core.Repo do
  use Ecto.Repo, otp_app: :core, adapter: Sqlite.Ecto2

  def init(_type, config) do
    unless config[:database] do
      database = Path.join(System.get_env("HOME"), "/.db/hecateros.sqlite3")
      {:ok, [database: database] ++ config}
    else
      {:ok, config}
    end
  end
end

defmodule Core.RepoInstrumenter do
  use Prometheus.EctoInstrumenter
end
