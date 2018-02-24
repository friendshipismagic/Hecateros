defmodule Core.Chan do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__
  alias Core.Admin
  alias Core.Repo

  schema "chans" do
    field :slug, :string
    field :name, :string
    many_to_many :admins, Core.Admin,
                  join_through: "chan_admins"

    has_many :links, Core.Link

    timestamps()
  end

  @type t :: %__MODULE__{name: String.t, slug: String.t}

  @doc false
  def changeset(%Chan{} = chan, attrs \\ %{}) do
    chan
    |> Repo.preload(:admins)
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> validate_format(:name, ~r/#.*/, message: "The channel name must begin with at least a # character")
    |> put_assoc(:admins, parse_admins(Map.get(attrs, :admins, [])))
  end

  def parse_admins(admins) when is_list(admins) do
    admins
    |> Enum.map(fn c -> get_or_insert_admin(c) end)
  end

  defp get_or_insert_admin(account_name) do
    Repo.get_by(Admin, account_name: account_name) ||
      Repo.insert!(%Admin{account_name: account_name})
  end
end
