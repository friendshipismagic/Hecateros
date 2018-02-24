defmodule Core.Link do
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.{Tag,Repo,Link}
  require Logger

  schema "links" do
    field        :url,         :string
    field        :description, :string
    field        :title,       :string
    belongs_to   :chan, Core.Chan
    many_to_many :tags, Core.Tag,
                 join_through: "tagging"

    timestamps()
  end

  def changeset(%Link{} = link, attrs \\ %{}) do
    link
    |> cast(attrs, [:url, :title, :description])
    |> validate_required([:url, :title, :description])
    |> put_assoc(:tags, parse_tags(attrs.tags))
  end

  def parse_tags(tags) when is_list(tags) do
    tags
    |> Enum.map(fn t -> get_or_insert_tag(t) end)
  end

  defp get_or_insert_tag(name) do
    Repo.get_by(Tag, name: name) ||
      Repo.insert!(%Tag{name: name})
  end
end
