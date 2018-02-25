defmodule Core.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "tags" do
    field    :name, :string
    many_to_many :links, Core.Link,
                 join_through: "tagging"
    
    timestamps()
  end

  def changeset(%Tag{} = tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
