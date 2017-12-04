defmodule IRC do
  @moduledoc """
  Documentation for IRC.
  """
  alias Core.Repo
  alias Core.Chan
  import Ecto.Changeset, only: [change: 2]

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
    :timer.sleep 500
    add_admin(chan_name, user.nick)
    banner = File.read!("priv/new_chan_admin.txt")
             |> String.replace("\n\n", "\n \n") 
             |> String.split("\n")

    Enum.each(banner, fn msg -> 
      ExIrc.Client.msg(client, :privmsg, user.nick, msg)
    end)
  end

  def add_admin(chan_name, user) do
    Chan
    |> Repo.get_by(name: chan_name)
    |> Repo.preload(:admins)
    |> Chan.changeset(%{admins: [user]})
    |> Repo.update
  end
end
