defmodule Web.ChanController do
  use Web, :controller

  def show(conn, %{"slug" => slug}) do
    case Core.get_links(:chan, slug) do
      nil -> conn
             |> put_status(404)
             |> render("404.html")
      chan ->
      tags = chan
             |> Map.get(:links)
             |> Enum.map(fn l -> l.tags end)
             |> List.flatten
             |> Enum.map(fn t -> t.name end)
             |> Enum.uniq
        render conn, "chan.html", chan: chan, tags: tags
    end
  end
end
