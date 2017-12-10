defmodule IRC.Messages do
  @moduledoc "This module handles all tasks related to parsing the messages received by the bot"

  alias IRC.Auth
  require Logger

  def parse("url " <> channel, username) do
    with {:ok, :authed} <- Auth.check_auth(username),
         {:ok, :admin}  <- Auth.check_admin(username, channel),
         {:ok, url}    <- Core.gib_slug(channel, username) do
           {:ok, url}
    else
      {:error, :nochan}  -> {:error, "Bien essayé, tocard…"}
      {:error, :noadmin} -> {:error, "…\nnon."}
    end
  end

  def parse(msg, username) do
    Logger.debug "[PRIVMSG] received \"#{msg}\" from #{username}"
    {:error, :noparse}
  end
end
