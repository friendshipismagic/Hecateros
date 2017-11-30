defmodule IRC.ConnectionHandler do
  use GenServer
  require Logger
  alias IRC.{Event,Plugins,State}

  def start_link(%State{}=state) do
    GenServer.start_link __MODULE__, state, name: __MODULE__
  end

  def init(state) do
    Logger.debug("[State dump] " <> inspect state)
    ExIrc.Client.add_handler(state.client, self())
    if state.tls? do
      ExIrc.Client.connect_ssl!(state.client, state.host, state.port)
    else
      ExIrc.Client.connect!(state.client, state.host, state.port)
    end
    Logger.info(IO.ANSI.green() <> "IRC Application started!" <> IO.ANSI.reset())
    {:ok, state}
  end

  def handle_info({:connected, _server, _port}, state) do
    Logger.info(IO.ANSI.green() <> "Establishing connection to #{state.host}" <> IO.ANSI.reset())
    
    ExIrc.Client.logon state.client, state.pass, state.nickname, state.username, state.realname
    {:noreply, state}
  end

  def handle_info(:disconnected, _state) do
    Logger.debug "Disconnected from server"
    {:noreply, nil}
  end

  def handle_info(:logged_in, state) do
    Logger.info(IO.ANSI.green() <> "Logged in!" <> IO.ANSI.reset())
    Logger.debug "Joining " <> Enum.join(state.channels, ", ")
    case state.channels do
      [] -> nil
       _ -> Enum.each(state.channels, &ExIrc.Client.join(state.client, &1))
    end
    {:noreply, state}
  end

  def handle_info({:received, _message, _sender}, state) do
    Logger.warn "I don't take personal requests."
    {:noreply, state}
  end

  def handle_info({:received, message, sender, chan}, state) do
    IRC.EventHandler.notify(%Event{message: message, sender: sender, chan: chan})
    {:noreply, state}
  end

  def handle_info(message, state) do
    Logger.debug "[Message] #{inspect(message)}"
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.info "[TERMINATE] #{inspect(reason)}"
    ExIrc.Client.stop!(state.client)
    reason
  end
end
