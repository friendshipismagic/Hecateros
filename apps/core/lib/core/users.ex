defmodule Core.Users do

  alias Core.{Repo,Chan}
  import Ecto.Query
  require Logger

  def check_admin(username, channel) do
    case Repo.one(from c in Chan, where: c.name == ^String.downcase(channel), preload: [:admins])  do
      %Chan{}=chan -> 
        if chan |> Map.get(:admins) |> Enum.any?(fn a -> a.nick == username end) do
          {:ok, :admin}
        else
          {:error, :noadmin}
        end
      nil   -> {:error, :nochan}
    end
  end

  def add_admin(chan_name, user) do
    Logger.info "[Core] Adding admin #{user} on #{chan_name}"
    chan = Repo.get_by(Chan, name: String.downcase(chan_name))
    if chan do
      chan
      |> Repo.preload(:admins)
      |> Chan.changeset(%{admins: [user]})
      |> Repo.update
    else
      Logger.error "nil channel! cannot add admin!"
      :error
    end
  end
end
