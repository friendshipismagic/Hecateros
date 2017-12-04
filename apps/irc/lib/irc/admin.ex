defmodule IRC.Admin do
  @moduledoc "This module handles all tasks related to the bot's administration"

  require Logger

  def is_authed?(username, client) do
    {:error, :noimpl}
  end

  def parse("url " <> channel, username) do
    case Core.gib_slug(channel, username) do
      {:ok, slug} -> {:ok, Web.Router.Helpers.chan_url(Web.Endpoint, :show, slug)}
      {:error, :nochan}  -> {:ok, "Bien essayé, tocard…"}
      {:error, :noadmin} -> {:ok, "Si t'es pas admin tu vas pas aller bien loin…"}
    end
  end

  def parse(msg, username) do
    Logger.debug "[PRIVMSG] received \"#{msg}\" from #{username}"
    {:error, :noparse}
  end
end
