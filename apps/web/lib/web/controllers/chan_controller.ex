defmodule Web.ChanController do
  use Web, :controller

  def show(conn, %{"slug" => slug}) do
    case Core.get_links(slug) do
      nil -> conn
             |> put_status(404)
             |> render("404.html")
      chan ->
        render conn, "chan.html", chan: chan
    end
  end
end
