defmodule IRC.Application do
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    conf  = Application.get_env(:irc, IRC.State)
    {:ok, client} = ExIrc.start_link!
    state = struct(IRC.State, (conf ++ [client: client]))

    children = [
      {IRC.ConnectionHandler, state}, # 1) This one receives the IRC message
      IRC.EventHandler,               # 2) And this one dispatches the messages to the plugins.
      IRC.Plugins.Links
    ]

    opts = [strategy: :one_for_one, name: IRC.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
