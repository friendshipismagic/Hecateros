defmodule Core.Repo.Migrations.Tagging do
  use Ecto.Migration

  def change do
    create table(:tagging, primary_key: false) do
      add :link_id, references(:links)
      add :tag_id,  references(:tags)
    end
  end
end
