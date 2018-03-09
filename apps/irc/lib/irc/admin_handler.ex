defmodule IRC.AdminHandler do

  alias IRC.State
  import IRC.Helpers, only: [get_whois: 1, check_auth: 1]
  import Core.Users, only: [check_admin: 2, add_admin: 2]
  require Logger
  use GenServer

  def start_link(%State{}=state) do
    GenServer.start_link(__MODULE__, state.client, name: __MODULE__)
  end

  def init(client) do
    ExIRC.Client.add_handler(client, self())
    {:ok, client}
  end

  def handle_info({:received, "show url " <> channel, sender}, client=state) do
    ExIRC.Client.whois(client, sender.nick)
    user    = get_whois(sender.nick)
    channel = channel |> String.downcase |> String.trim

    case get_url(channel, user) do
      {:ok, url} ->
        ExIRC.Client.msg(client, :privmsg, user.nick, url)
      {:error, :noadmin} ->
        ExIRC.Client.msg(client, :privmsg, user.nick, "You're not an admin for this channel.")
      {:error, :nochan} ->
        ExIRC.Client.msg(client, :privmsg, user.nick, "Am I getting old or did you misspell the channel's name?")
      {:error, :unauthed} -> 
        ExIRC.Client.msg(client, :privmsg, user.nick, "You don't seem registered with NickServ…")
    end
    {:noreply, state}
  end

  def handle_info({:received, "show admins " <> _channel, _sender}, state) do
    {:noreply, state}
  end

  def handle_info({:received, "add admin " <> rest, sender}, client=state) do
    [channel, nick] = String.split(rest, " ")
    ExIRC.Client.whois(client, nick)
    case check_and_add_admin(channel, nick) do
      {:ok, _} ->
        ExIRC.Client.msg(client, :privmsg, sender.nick, "Admin #{nick} succesfully added for #{channel}.")
      {:error, :invalid} ->
        ExIRC.Client.msg(client, :privmsg, sender.nick, "Invalid syntax. Please use `add admin <#channel> <nickname>")
      {:Error, :nochan} ->
        ExIRC.Client.msg(client, :privmsg, sender.nick, "Am I getting old or did you misspell the channel's name?")
    end
    {:noreply, state}
  end

  def handle_info({:received, msg, sender}, state) do
    Logger.debug "[Privmsg] “#{sender.nick}: #{msg}”"
    ExIRC.Client.msg(state, :privmsg, sender.nick, "I'm afraid I can't do that Dave…")
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  @spec get_url(String.t, %ExIRC.Whois{}) :: {:ok, String.t} | {:error, atom()}
  defp get_url(channel, user) do
    with {:ok, :authed} <- check_auth(user),
         {:ok, :admin}  <- check_admin(user, channel),
         {:ok, slug}    <- Core.gib_slug(channel) do
           {:ok, Web.Router.Helpers.chan_url(Web.Endpoint, :show, slug)}
    end
  end

  @spec check_and_add_admin(String.t, String.t) :: {:ok, Ecto.Changeset.t} | {:error, atom()}
  defp check_and_add_admin(channel, nick) do
    if channel == "" || nick == "" do
      {:error, :invalid}
    else
      user = get_whois(nick)
      add_admin(channel, user)
    end
  end
end
