defmodule Core.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :url, :string, null: false
      add :description, :string, null: false
      add :title, :string
      add :chan_id, references(:chans, on_delete: :delete_all)

      timestamps()
    end
  end
end
