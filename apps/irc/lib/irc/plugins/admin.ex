defmodule IRC.Plugins.Admin do
  @moduledoc "This module handles all tasks related to parsing the messages received by the bot"

  alias IRC.{EventHandler, Event}
  import Core.Users, only: [check_admin: 2, add_admin: 2]
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    EventHandler.subscribe(:private)
  end

  def handle_cast({:private, %Event{}=event}, state) do
    case parse(event.message, event.sender.nick, event.client) do
      {:ok, msg} ->
        ExIRC.Client.msg(event.client, :privmsg, event.sender.nick, msg)
      {:error, msg}  ->
        for m <- String.split(msg,"\n") do
          :timer.sleep(500)
          ExIRC.Client.msg(event.client, :privmsg, event.sender.nick, m)
          :timer.sleep(700)
        end
    end
    {:noreply, state}
  end

  @spec parse(String.t, String.t, pid()) :: {:ok, String.t} | {:error, String.t}
  def parse("url " <> channel, username, client) do
    with {:ok, :admin}  <- check_admin(username, channel),
         {:ok, :authed} <- check_auth(username, client),
         {:ok, slug}    <-  Core.gib_slug(channel) do
           {:ok, Web.Router.Helpers.chan_url(Web.Endpoint, :show, slug)}
    else
      {:error, :nochan}  -> {:error, "Bien essayé, tocard…"}
      {:error, :noadmin} -> {:error, "…\nnon."}
    end
  end

  def parse("add admin " <> rest, username, client) do
    r = String.split(rest, " ")
    Logger.debug (inspect r)
    case r do
      [_, ""]  -> {:error, "Syntax: add admin #channel Admin"}
      [channel, new_admin, _] ->
        with {:ok, :admin}  <- check_admin(username, channel),
             {:ok, :authed, account} <- check_auth(username, client) do
              add_admin(channel, account)
              {:ok, "Added admin #{new_admin} with NickServ account #{account}."}
        else
          {:error, :noadmin} -> {:error, "…\nnon."}
          {:error, :nochan}  -> {:error, "Bien essayé, tocard…"}
          {:error, :unauthed} -> 
            add_admin(channel, new_admin)
            {:ok, "Added admin #{new_admin} without NickServ checking."}
        end
    end
  end

  def parse(msg, username, client) do
    Logger.debug "[PRIVMSG] received \"#{msg}\" from #{username}"
    {:error, "Wat."}
  end
  
  def check_auth(username, client) do
    user = ExIRC.Client.whois(client, username)
    if user.account_name, do: {:ok, :authed, user.account_name}, else: {:error, :unauthed}
  end
end
