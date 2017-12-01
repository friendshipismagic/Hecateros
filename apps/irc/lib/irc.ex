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
               :pipeline
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

  def join_channel(params) do
    ExIrc.Client.join(params[:client], params[:chan])
    add_admin(params[:chan], params[:user].nick)
  end

  def add_admin(chan_name, user) do
    chan = Chan |> Repo.get_by(name: chan_name)
    chan
    |> Repo.preload(:admins)
    |> Chan.changeset(%{admins: [user]})
    |> Repo.update
  end
end
