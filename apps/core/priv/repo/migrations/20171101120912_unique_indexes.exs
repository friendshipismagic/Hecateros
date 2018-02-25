defmodule Core.Repo.Migrations.UniqueIndexes do
  use Ecto.Migration

  def change do
    create index(:tags, [:name], unique: true)
    create index(:chans, [:name], unique: true)
    create index(:links, [:url, :chan_id], unique: true)
  end
end
