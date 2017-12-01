defmodule Core.Repo.Migrations.ChanAdmins do
  use Ecto.Migration

  def change do
    create table(:chan_admins, primary_key: false) do
      add :chan_id, references(:chans)
      add :admin_id, references(:admins)
    end
  end
end
