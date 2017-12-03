defmodule IRC.Admin do
  @moduledoc "This module handles all tasks related to the bot's administration"


  def is_authed?(username, client) do
    {:error, :noimpl}
  end

  def parse("url " <> channel, username) do
    case Core.gib_slug(channel, username) do
      {:ok, slug} -> Web.Router.Helpers.chan_url(Web.Endpoint, :show, slug)
      {:error, :nochan}  -> "Bien essayé, tocard…"
      {:error, :noadmin} -> "Si t'es pas admin tu vas pas aller bien loin…"
    end
  end
end
