defmodule Core do
  @moduledoc """
  """
  alias Core.{Chan,Tag,Repo,Link}
  require Logger
  import Ecto.Query
  import Core.Users, only: [check_admin: 2]

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

  def create_chan(%{name: chan_name, slug: slug}) do
    chan = Chan.changeset(%Chan{}, %{name: String.downcase(chan_name), slug: slug})
    Chan
    |> Repo.get_by(name: String.downcase(chan_name)) || Repo.insert(chan)
    |> trace
    |> pack
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

  @spec gib_slug(String.t) :: {:ok, String.t}
  def gib_slug(channel) do
    Logger.debug("Channel: " <> channel)
    [slug] = Repo.all from c in Chan, where: c.name == ^channel,
                                      select: c.slug
    {:ok, slug}
  end

  # Helpers

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

  defp pack({:error, x}), do: {:error, x}
  defp pack({:ok, x}),   do: {:ok, x}
  defp pack(x),          do: {:ok, x}

  defp trace(x) do
    Logger.info("[TRACE] "<> inspect(x))
    x
  end

  def version, do: System.cmd("git", ~w(describe --always --tags HEAD)) |> elem(0) |> String.replace("\n", "")
end
