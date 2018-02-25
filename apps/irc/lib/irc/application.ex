defmodule IRC.Application do
  @moduledoc false

  use Application
  require Logger

  def start(_, _) do
    conf = Application.get_env(:irc, IRC.State)
    {:ok, client} = ExIRC.start_link!
    state = struct(IRC.State, (conf ++ [client: client]))

    plugins = [{IRC.AdminHandler,   state},
               {IRC.LinksHandler,   state},
               {IRC.ChannelHandler, state},
               {IRC.WhoisHandler,   state}
              ]

    children = [
      {IRC.ConnectionHandler, state}
    ] ++ plugins

    opts = [strategy: :one_for_one, name: IRC.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
