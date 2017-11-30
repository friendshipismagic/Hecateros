defmodule Web.ChanController do
  use Web, :controller

  def show(conn, %{"slug" => slug}) do
    render conn, "chan.html", chan: Core.get_links({:chan, slug})  
  end
end
