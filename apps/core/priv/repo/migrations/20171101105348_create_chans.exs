defmodule Core.Repo.Migrations.CreateChans do
  use Ecto.Migration

  def change do
    create table(:chans) do
      add :name, :string, null: false
      add :slug, :string, null: false

      timestamps()
    end
  end
end
