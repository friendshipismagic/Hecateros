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

  def notify(topic, %Event{}=event) when is_atom(topic) do
    Registry.dispatch(__MODULE__, topic, fn entries ->
      for {pid, _} <- entries, do: GenServer.cast(pid, {topic, event})
    end)
  end

  def subscribe(topic) when is_atom(topic) do
    Registry.register(__MODULE__, topic, [])
  end
end
