defmodule Core do
  @moduledoc """
  """
  alias Core.{Chan,Tag,Repo,Link}
  require Logger
  import Ecto.Query

  def get_links({:chan, slug}) do
    Chan
    |> Repo.get_by(slug: slug)
    |> Repo.preload([links: [:tags]])
  end

  def insert_link(%{chan: chan_name, tags: tags, url: url, title: title}) do
    case create_chan(%{name: chan_name, slug: create_slug()}) do
      %Chan{}=chan -> create_link %{chan: chan, tags: tags, url: url, title: title}
      {:ok, chan}  -> create_link %{chan: chan, tags: tags, url: url, title: title}
    end
  end

  def create_chan(attributes) do
    chan = Chan.changeset(%Chan{}, attributes)
    Chan
    |> Repo.get_by(name: attributes.name) || Repo.insert(chan)
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

  defp pack({:ok, x}), do: {:ok, x}
  defp pack(x),        do: {:ok, x}

  defp trace(x) do
    Logger.debug("[TRACE] "<> inspect(x))
    x
  end
  def create_slug(), do: Ecto.UUID.generate |> String.split("-") |> hd
end
