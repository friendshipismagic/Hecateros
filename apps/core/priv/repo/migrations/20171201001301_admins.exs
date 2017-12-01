defmodule Core.Repo.Migrations.Admins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add :nick, :string, null: false
      add :chan, references(:chans)

      timestamps()
    end
  end
end
