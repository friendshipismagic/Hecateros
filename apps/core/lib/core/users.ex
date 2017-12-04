defmodule Core.Users do

  alias Core.{Repo,Chan}
  import Ecto.Query

  def is_admin?(username, channel) do
    case Repo.one(from c in Chan, where: c.name == ^String.downcase(channel), preload: [:admins])  do
      %Chan{}=chan -> 
        chan
          |> Map.get(:admins)
          |> Enum.any?(fn a -> a.nick == username end)
      nil   -> false
    end
  end
end
