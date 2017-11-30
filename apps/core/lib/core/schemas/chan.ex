defmodule Core.Chan do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "chans" do
    field :slug, :string
    field :name, :string
    has_many :links, Core.Link

    timestamps()
  end

  @type t :: %__MODULE__{name: String.t}

  @doc false
  def changeset(%Chan{} = chan, attrs) do
    chan
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name])
    |> validate_format(:name, ~r/#.*/, message: "The channel name must begin with at least a # character")
  end

end
