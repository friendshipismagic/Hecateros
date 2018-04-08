defmodule IRC.AdminHandler do

  alias IRC.State
  import IRC.Helpers, only: [get_whois: 1, check_auth: 1]
  import Core.Users, only: [check_admin: 2, add_admin: 2]
  alias Core.{Chan,Repo}
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

  def handle_info({:received, "summary " <> channel, sender}, client=state) do
    channel = channel |> String.downcase |> String.trim

    response = sender
               |> is_admin(channel, client)
               |> process_auth({:summary, channel})
               |> String.split("\n")
    Enum.each(response, fn msg ->
      ExIRC.Client.msg(client, :privmsg, sender.nick, msg)
    end)
    {:noreply, state}
  end

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

  def handle_info({:received, "url filter " <> rest, sender}, client=state) do
    IO.puts rest
    case String.split(String.downcase(rest), " ") do
      [channel, "show"] ->
        response = sender
                   |> is_admin(channel, client)
                   |> process_auth({:show_filter_url, channel})
        ExIRC.Client.msg(client, :privmsg, sender.nick, response)

      [channel, switch] when switch in ["on", "off"] ->
        response = sender
                   |> is_admin(channel, client)
                   |> process_auth({:filter_url, channel, switch})

        ExIRC.Client.msg(client, :privmsg, sender.nick, response)

      [channel, command, urls] when command in ["add", "delete", "replace"] ->
        urllist = MapSet.new(String.split(urls, ","))
        response = case command do
                    "add" ->
                      sender
                      |> is_admin(channel, client)
                      |> process_auth({:add_url_filter, channel, urllist})
                    "delete" ->
                      sender
                      |> is_admin(channel, client)
                      |> process_auth({:delete_url_filter, channel, urllist})
                    "replace" ->
                      sender
                      |> is_admin(channel, client)
                      |> process_auth({:replace_url_filter, channel, urllist})
                  end
        ExIRC.Client.msg(client, :privmsg, sender.nick, response)
      _ ->
        ExIRC.Client.msg(client, :privmsg, sender.nick, "Invalid syntax. Please use `url filter <#channel> <on|off>`")
    end
    {:noreply, state}
  end

  def handle_info({:received, "tag filter " <> rest, sender}, client=state) do
    IO.puts rest
    case String.split(String.downcase(rest), " ") do
      [channel, "show"] ->
        response = sender
                   |> is_admin(channel, client)
                   |> process_auth({:show_filter_tag, channel})
        ExIRC.Client.msg(client, :privmsg, sender.nick, response)

      [channel, switch] when switch in ["on", "off"] ->
        response = sender
                   |> is_admin(channel, client)
                   |> process_auth({:filter_tag, channel, switch})

        ExIRC.Client.msg(client, :privmsg, sender.nick, response)

      [channel, command, tags] when command in ["add", "delete", "replace"] ->
        taglist = MapSet.new(String.split(tags, ","))
        response = case command do
                    "add" ->
                      sender
                      |> is_admin(channel, client)
                      |> process_auth({:add_tag_filter, channel, taglist})
                    "delete" ->
                      sender
                      |> is_admin(channel, client)
                      |> process_auth({:delete_tag_filter, channel, taglist})
                    "replace" ->
                      sender
                      |> is_admin(channel, client)
                      |> process_auth({:replace_tag_filter, channel, taglist})
                  end
        ExIRC.Client.msg(client, :privmsg, sender.nick, response)
      _ ->
        ExIRC.Client.msg(client, :privmsg, sender.nick, "Invalid syntax. Please use `tag filter <#channel> <on|off>`")
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

  ### URL filter ###

  def process_message({:show_filter_url, channel}) do
    urllist = Repo.get_by(Chan, name: channel) |> Map.get(:settings) |> Map.get(:url_filters)
    if (urllist != [] and urllist != nil) do
      "Forbidden URLs for #{channel} are: #{Enum.join(urllist, ", ")}."
    else
      "No URLs are currently filtered…"
    end
  end

  def process_message({:filter_url, channel, switch}) do
    Chan.switch_url_filters(String.to_atom(switch), channel)
    "Switched urls filter #{switch} on #{channel}"
  end

  def process_message({:add_url_filter, channel, urllist}) do
    chan = Repo.get_by(Chan, name: channel)
    Chan.add_url_filters(chan, urllist)
    "URL(s) #{Enum.join(urllist, ", ")} added to the filter."
  end

  def process_message({:delete_url_filter, channel, urllist}) do
    chan = Repo.get_by(Chan, name: channel)
    Chan.delete_url_filters(chan, urllist)
    "URL(s) #{Enum.join(urllist, ", ")} deleted from the filter."
  end

  def process_message({:replace_url_filter, channel, urllist}) do
    chan = Repo.get_by(Chan, name: channel)
    Chan.replace_url_filters(chan, urllist)
    "URL(s) #{Enum.join(urllist, ", ")} are now the filter."
  end

  ### Tag filter ###

  def process_message({:show_filter_tag, channel}) do
    taglist = Repo.get_by(Chan, name: channel) |> Map.get(:settings) |> Map.get(:tag_filters)
    if (taglist != [] and taglist != nil) do
      "Authorized tags for #{channel} are: #{Enum.join(taglist, ", ")}."
    else
      "No tags are currently filtered…"
    end
  end

  def process_message({:filter_tag, channel, switch}) do
    Chan.switch_tag_filters(String.to_atom(switch), channel)
    "Switched tags filter #{switch} on #{channel}"
  end

  def process_message({:add_tag_filter, channel, taglist}) do
    chan = Repo.get_by(Chan, name: channel)
    Chan.add_tag_filters(chan, taglist)
    "Tag(s) #{Enum.join(taglist, ", ")} added to the filter."
  end

  def process_message({:delete_tag_filter, channel, taglist}) do
    chan = Repo.get_by(Chan, name: channel)
    Chan.delete_tag_filters(chan, taglist)
    "Tag(s) #{Enum.join(taglist, ", ")} deleted from the filter."
  end

  def process_message({:replace_tag_filter, channel, taglist}) do
    chan = Repo.get_by(Chan, name: channel)
    Chan.replace_tag_filters(chan, taglist)
    "Tag(s) #{Enum.join(taglist, ", ")} are now the filter."
  end

  ### Misc ###

  def process_message({:summary, channel_name}) do
    chan = Repo.get_by(Chan, name: channel_name) |> Repo.preload(:admins)
    tag_filters_status =  if chan.settings.has_tag_filter? do
                            "[\x02\x0303activated\x03\x0F]  "
                          else
                            "[\x02\x0304deactivated\x03\x0F]"
                          end

    url_filters_status =  if chan.settings.has_url_filter? do
                            "[\x02\x0303activated\x03\x0F]  "
                          else
                            "[\x02\x0304deactivated\x03\x0F]"
                          end
    url_filters = Enum.join(chan.settings.url_filters, ", ")
    tag_filters = Enum.join(chan.settings.tag_filters, ", ")
    
    admins = Enum.map(chan.admins, fn a -> a.account_name end) |> Enum.join(", ")
    """
    \x03\x1FSummary for #{channel_name}\x0F
    URL: #{process_message({:show_url, channel_name})}
     
    \x03\x02Admins:\x0F\x03 #{admins}
     
    #{tag_filters_status} Tag filters: #{tag_filters}
    #{url_filters_status} URL filters: #{url_filters}
    """
  end

  def process_message({:show_url, channel}) do
    {:ok, slug} = Chan.gib_slug(channel)
    Web.Router.Helpers.chan_url(Web.Endpoint, :show, slug)
  end

  def process_message({:add_admin, channel, nick}) do
    case check_and_add_admin(channel, nick) do
      {:ok, _} ->
        "Admin #{nick} succesfully added for #{channel}."
      {:error, :invalid} ->
        "Invalid syntax. Please use `add admin <#channel> <nickname>."
    end
  end
end
