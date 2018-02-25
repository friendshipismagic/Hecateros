defmodule Web.TagController do
  use Web, :controller

  alias Core.{Tag, Chan, Repo}

  def show(conn, %{"slug" => slug, "tag" => tag_name}) do
    tag   = Repo.get_by(Tag, name: tag_name)
    chan  = Repo.get_by(Chan, slug: slug)
    links = Core.get_links(:tag, tag, chan)
    # links = Repo.preload(tag, :links) |> Map.get(:links) |> Enum.filter(fn link -> link.chan_id == chan.id end)

    render conn, "tag.html", [links: links, slug: slug, tag: tag_name]
  end
end
