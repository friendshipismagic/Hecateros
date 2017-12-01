defmodule Core.Admin do
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.{Admin,Chan}

  schema "admins" do
    field :nick, :string
    many_to_many :chans, Core.Chan,
                  join_through: "chan_admins"

    timestamps()
  end

  def changeset(%Admin{}=admin, attrs \\ %{}) do
    admin 
    |> cast(attrs, [:nick])
  end
end
