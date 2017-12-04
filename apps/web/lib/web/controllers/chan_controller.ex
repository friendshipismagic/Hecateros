defmodule Web.ChanController do
  use Web, :controller

  def show(conn, %{"slug" => slug}) do
    if Core.get_links({:chan, slug}) do
      render conn, "chan.html", chan: Core.get_links({:chan, slug})
    else
      conn
      |> put_status(404)
      |> render("404.html")
    end
  end
end
