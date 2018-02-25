defmodule Core.Users do

  alias Core.{Repo,Chan}
  import Ecto.Query
  require Logger

  @spec check_admin(%ExIRC.Whois{}, String.t) :: {:ok, :admin} | {:error, :noadmin | :nochan}
  def check_admin(user, channel) do
    case Repo.one(from c in Chan, where: c.name == ^String.downcase(channel), preload: [:admins])  do
      %Chan{}=chan -> 
        if chan |> Map.get(:admins) |> Enum.any?(fn a -> a.account_name == user.account_name end) do
          {:ok, :admin}
        else
          {:error, :noadmin}
        end
      nil   -> {:error, :nochan}
    end
  end

  @spec add_admin(String.t, %ExIRC.Whois{}) :: {:ok, Ecto.Changeset.t} | {:error, any()}
  def add_admin(chan, user) do
    Logger.info "[Core] Adding admin #{user.nick} on #{chan}"
    channel = Repo.get_by(Chan, name: String.downcase(chan))
    if channel do
      channel
      |> Repo.preload(:admins)
      |> Chan.changeset(%{admins: [user.account_name]})
      |> Repo.update
    else
      Logger.error "Channel #{chan} doesn't exist."
      {:error, :nochan}
    end
  end
end
