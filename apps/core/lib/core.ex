defmodule Core do
  @moduledoc """
  """
  alias Core.{Chan,Tag,Repo,Link}
  require Logger
  import Ecto.Query

  def get_links(slug) do
    links_query = from l in Link, order_by: [desc: :inserted_at], preload: [:tags]
    Repo.one(from c in Chan, where: c.slug == ^slug, limit: 1, preload: [links: ^links_query])
  end

  def insert_link(%{chan: chan_name, tags: tags, url: url, title: title}) do
    case create_chan(%{name: chan_name, slug: create_slug()}) do
      {:ok, chan}  -> create_link %{chan: chan, tags: tags, url: url, title: title}
      %Chan{}=chan -> create_link %{chan: chan, tags: tags, url: url, title: title}
    end
  end

  def create_chan(%{chan: chan_name, slug: slug}) do
    chan = Chan.changeset(%Chan{}, %{chan: String.downcase(chan_name), slug: slug})
    Chan
    |> Repo.get_by(name: chan_name) || Repo.insert(chan)
    |> trace
    |> pack
  end

  @doc "Expects a map with the keys :url, :tags, :chan, :title"
  def create_link(attributes) do
    case check_duplicate({:url, attributes.url, attributes.chan.name}) do
      :ok ->
        chan = attributes.chan

        link = Ecto.build_assoc(chan, :links, %{url: attributes.url, title: attributes.title})

        link |> Link.changeset(%{tags: attributes.tags})
             |> Repo.insert!

        Logger.debug "[Link] #{link.url} with tags #{inspect attributes.tags} in #{attributes.chan.name} recorded!"
      :duplicate ->
        {:error, :duplicate}
    end
  end

  def gib_slug(channel, username) do
    with %Chan{} = channel <- Repo.one(from c in Chan, where: like(c.name, ^"#{channel}"), limit: 1),
         admins <- Repo.preload(channel, :admins) |> Map.get(:admins),
         true <- Enum.any?(admins, fn a -> a.nick == username end) do
        {:ok, channel.slug}
    else
      nil   -> {:error, :nochan}
      false -> {:error, :noadmin}
    end
  end


  # Helpers

  defp check_duplicate({:url, url, chan}) do
    Logger.debug "Wondering if #{url} in #{chan} already exists…"
    query = from c in Chan, join: l in Link, where: c.name == ^chan and l.url == ^url and c.id == l.chan_id, select: l
    case Repo.all(query) do
      [] ->
        Logger.debug "Nope, doesn't."
        :ok 
      [link] ->
        :duplicate
    end
  end

  def create_slug(), do: Ecto.UUID.generate |> String.split("-") |> hd

  defp pack({:ok, x}), do: {:ok, x}
  defp pack(x),        do: {:ok, x}

  defp trace(x) do
    Logger.debug("[TRACE] "<> inspect(x))
    x
  end
end
