defmodule Web.ChanController do
  use Web, :controller

  def show(conn, %{"slug" => slug}) do
    if chan=Core.get_links({:chan, slug}) do
      render conn, "chan.html", chan: chan
    else
      conn
      |> put_status(404)
      |> render("404.html")
    end
  end
end
