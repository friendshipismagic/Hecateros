defmodule IRC.AdminHandler do

  alias IRC.State
  import IRC.Helpers, only: [get_whois: 1, check_auth: 1]
  import Core.Users, only: [check_admin: 2, add_admin: 2]
  alias Core.Chan
  require Logger
  use GenServer

  def start_link(%State{}=state) do
    GenServer.start_link(__MODULE__, state.client, name: __MODULE__)
  end

  def init(client) do
    ExIRC.Client.add_handler(client, self())
    {:ok, client}
  end


  #### Messages ####

  def handle_info({:received, "show url " <> rest, sender}, client=state) do
    channel = rest |> String.downcase |> String.trim

    response = sender
               |> is_admin(channel, client)
               |> process_auth({:show_url, channel})

    ExIRC.Client.msg(client, :privmsg, sender.nick, response)
    {:noreply, state}
  end

  def handle_info({:received, "add admin " <> rest, sender}, client=state) do
    [channel, nick] = String.split(rest, " ")
    response = sender
               |> is_admin(channel, client)
               |> process_auth({:add_admin, channel, nick})

    ExIRC.Client.msg(client, :privmsg, sender.nick, response)
    {:noreply, state}
  end

  def handle_info({:received, "filter " <> rest, sender}, client=state) do
    case String.split(String.downcase(rest), " ") do
      [channel, target] when target in ["on", "off"] ->
        response = sender
                   |> is_admin(channel, client)
                   |> process_auth({:filter, channel, target})
        ExIRC.Client.msg(client, :privmsg, sender.nick, response)
      _ ->
        ExIRC.Client.msg(client, :privmsg, sender.nick, "Invalid syntax. Please use `filter <#channel> <on|off>`")
    end
    {:noreply, state}
  end

  def handle_info({:received, msg, sender}, state) do
    Logger.debug "[Privmsg] “#{sender.nick}: #{msg}”"
    ExIRC.Client.msg(state, :privmsg, sender.nick, "I'm afraid I can't do that Dave…")
    {:noreply, state}
  end

  ##################

  def handle_info(_, state) do
    {:noreply, state}
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

  def is_admin(sender, channel, client) do
    ExIRC.Client.whois(client, sender.nick)
    user = get_whois(sender.nick)
    with {:ok, :authed} <- check_auth(user),
         {:ok, :admin}  <- check_admin(user, channel),
          do: {:ok, :admin}
  end

  def process_auth({:ok, :admin}, message) do
    process_message(message)
  end

  def process_auth({:error, :noadmin}, _) do
     "You're not an admin for this channel."
  end

  def process_auth({:error, :nochan}, _) do
    "Am I getting old or did you misspell the channel's name?"
  end

  def process_auth({:error, :unauthed}) do
    "You don't seem registered with NickServ…"
  end

  def process_message({:show_url, channel}) do
    {:ok, slug} = Chan.gib_slug(channel)
    Web.Router.Helpers.chan_url(Web.Endpoint, :show, slug)
  end

  def process_message({:filter, channel, switch}) do
    Chan.switch_filters(String.to_atom(switch), channel)
    "Turned filters #{switch} for #{channel}"
  end

  def process_message({:add_admin, channel, nick}) do
    case check_and_add_admin(channel, nick) do
      {:ok, _} ->
        "Admin #{nick} succesfully added for #{channel}."
      {:error, :invalid} ->
        "Invalid syntax. Please use `add admin <#channel> <nickname>"
    end
  end
end
