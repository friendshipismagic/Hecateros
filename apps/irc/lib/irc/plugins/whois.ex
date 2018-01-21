defmodule IRC.Plugins.Whois do
  alias IRC.{EventHandler}
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    EventHandler.subscribe(:whois)
    {:ok, :ok}
  end

  def handle_cast({:whois, event}, state) do
    {:noreply, state}
  end

  def whois(client, nickname) do
    ExIRC.Client.whois(client, nickname)
  end
end
