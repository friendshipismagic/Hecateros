defmodule IRC do
  @moduledoc """
  Documentation for IRC.
  """
  alias Core.{Repo,Chan,Users}
  import Users, only: [check_admin: 2]
  require Logger

  defmodule State do
    defstruct [:client,
               :channels,
               :handlers,
               :host,
               :nickname,
               :pass,
               :port,
               :realname,
               :tls?,
               :username,
              ]
  end

  defmodule Event do
    defstruct [:message,
               :sender,
               :tags,
               :url,
               :title,
               :chan
              ]
  end

  def join_channel(%{chan: chan_name, user: user, client: client}) do
    Core.create_chan(%{name: chan_name, slug: Core.create_slug()})
    ExIrc.Client.join(client, chan_name)
    add_admin(chan_name, user.nick)
    :timer.sleep(300)
    unless check_admin(user.nick, chan_name) do
      send_banner(client, user.nick)
    end
  end

  def add_admin(chan_name, user) do
    chan = Repo.get_by(Chan, name: String.downcase(chan_name))
    if chan do
      chan
      |> Repo.preload(:admins)
      |> Chan.changeset(%{admins: [user]})
      |> Repo.update
    else
      Logger.error "nil channel! cannot add admin!"
    end
  end

  defp send_banner(client, nick) do
    banner = File.read!("priv/new_chan_admin.txt")
             |> String.replace("\n\n", "\n \n") 
             |> String.split("\n")

    Enum.each(banner, fn msg -> 
      ExIrc.Client.msg(client, :privmsg, nick, msg)
    end)
  end
end
