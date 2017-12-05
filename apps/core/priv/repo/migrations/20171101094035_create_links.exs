defmodule Core.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :url, :string, null: false
      add :chan_id, references(:chans, on_delete: :delete_all)
      add :title, :string

      timestamps()
    end
  end
end
