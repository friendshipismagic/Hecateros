defmodule IRC.Plugins.Channel do
  alias IRC.{EventHandler, Event}
  require Logger
  use GenServer


  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    EventHandler.subscribe(:invited)
    {:ok, :ok}
  end

  def handle_cast({:invited, %Event{}=event}, state) do
    Logger.debug "Received broadcasted invitation"
    Core.create_chan(%{name: event.chan, slug: Core.create_slug()})
    ExIRC.Client.join(event.client, event.chan)
    unless Core.Users.check_admin(event.sender, event.chan) do
      send_banner(event.client, event.sender)
    end
    Core.Users.add_admin(event.chan, event.sender)
    {:noreply, state}
  end

  defp send_banner(client, nick) do
    banner = File.read!("priv/new_chan_admin.txt")
             |> String.replace("\n\n", "\n \n") 
             |> String.split("\n")

    Enum.each(banner, fn msg -> 
      ExIRC.Client.msg(client, :privmsg, nick, msg)
    end)
  end
end
