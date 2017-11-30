defmodule IRC.EventHandler do
  alias IRC.Event
  use GenServer
  require Logger

  def start_link(_) do
    Registry.start_link(keys: :duplicate, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info(IO.ANSI.green <> "Event Handler started." <> IO.ANSI.reset)
    {:ok, :ok}
  end

  def notify(%Event{}=message) do
    Registry.dispatch(__MODULE__, :irc, fn entries ->
      for {pid, _} <- entries, do: GenServer.cast(pid, {:irc, message})
    end)
  end

  def subscribe() do
    Registry.register(__MODULE__, :irc, [])
  end
end
