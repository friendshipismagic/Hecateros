defmodule Core.Repo do
  use Ecto.Repo, otp_app: :core, adapter: Sqlite.Ecto2
end
