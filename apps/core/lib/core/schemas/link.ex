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

  ###########
  # Helpers #
  ###########

  def get_links(:chan, slug) do
    links_query = from l in Link, order_by: [desc: :inserted_at], preload: [:tags]
    Repo.one(from c in Chan, where: c.slug == ^slug, limit: 1, preload: [links: ^links_query])
  end

  def get_links(:tag, tag, chan) do
    query = from l in Link, where: l.chan_id == ^chan.id, order_by: l.inserted_at
    tag
    |> Repo.preload([links: query])
    |> Map.get(:links)
  end

  def insert_link(%{chan: chan_name, tags: tags, url: url, title: title, description: desc}) do
    case create_chan(%{name: String.downcase(chan_name), slug: create_slug()}) do
      {:ok, chan}  -> create_link %{chan: chan, tags: tags, url: url, title: title, description: desc}
      %Chan{}=chan -> create_link %{chan: chan, tags: tags, url: url, title: title, description: desc}
    end
  end

  @doc "Expects a map with the keys :url, :tags, :chan, :title"
  def create_link(attributes) do
    case check_duplicate({:url, attributes.url, attributes.chan.name}) do
      :ok ->
        chan = attributes.chan

        link = Ecto.build_assoc(chan, :links, %{url: attributes.url, title: attributes.title, description: attributes.description})

        link |> Link.changeset(%{tags: attributes.tags})
             |> Repo.insert!

        Logger.debug "[Link] #{link.url} with tags #{inspect attributes.tags} in #{attributes.chan.name} recorded!"
      :duplicate ->
        {:error, :duplicate}
    end
  end

  defp check_duplicate({:url, url, chan}) do
    Logger.debug "Wondering if #{url} in #{chan} already exists…"
    query = from c in Chan, join: l in Link,
                            where: c.name == ^String.downcase(chan)
                            and l.url == ^url and c.id == l.chan_id,
                            select: l
    case Repo.all(query) do
      [] ->
        Logger.debug "Nope, doesn't."
        :ok
      [_link] ->
        :duplicate
    end
  end

  def create_slug(), do: Ecto.UUID.generate |> String.split("-") |> hd
end
