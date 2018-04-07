defmodule Core.Chan do
  alias Core.{Admin,Repo,Chan,Link}
  alias __MODULE__
  import Ecto.Changeset
  import Ecto.Query
  require Logger
  use Ecto.Schema

  schema "chans" do
    field :slug, :string
    field :name, :string

    embeds_one :settings, Settings do
      field :has_filter?, :boolean
      field :filters, {:array, :string}
    end
    many_to_many :admins, Admin,
                  join_through: "chan_admins"

    has_many :links, Link

    timestamps()
  end

  @type t :: %__MODULE__{name: String.t, slug: String.t}

  @doc false
  def changeset(%Chan{} = chan, attrs \\ %{}) do
    chan
    |> Repo.preload(:admins)
    |> cast(attrs, [:name, :slug])
    |> cast_embed(:settings)
    |> validate_required([:name, :slug])
    |> validate_format(:name, ~r/#.*/, message: "The channel name must begin with at least a # character")
    |> put_assoc(:admins, parse_admins(Map.get(attrs, :admins, [])))
  end

  def register_changeset(%Chan{} = chan, attrs \\ %{}) do
    changeset(chan, attrs)
    |> put_change(:settings, %Chan.Settings{has_filter?: false, filters: []})
  end

  defp parse_admins(admins) when is_list(admins) do
    admins
    |> Enum.map(fn c -> get_or_insert_admin(c) end)
  end

  defp get_or_insert_admin(account_name) do
    Repo.get_by(Admin, account_name: account_name) ||
      Repo.insert!(%Admin{account_name: account_name})
  end


  ###########
  # Helpers #
  ###########


  @doc "Take a `%Core.Chan{}` struct, or just its name, and flick the switch for the filter feature."
  def switch_filters(:on, chan) when is_binary(chan) do
    Chan
    |> Repo.get_by(name: chan)
    |> turn_filter_on
  end

  def switch_filters(:off, chan) when is_binary(chan) do
    Chan
    |> Repo.get_by(Chan, name: chan)
    |> turn_filter_off
  end

  def turn_filter_on(%Chan{}=chan) do
    chg = Ecto.Changeset.change(chan.settings) |> Ecto.Changeset.put_change(:has_filter?, true)
    chan
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_embed(:settings, chg)
    |> Repo.update!
  end

  def turn_filter_off(%Chan{}=chan) do
    chg = Ecto.Changeset.change(chan.settings) |> Ecto.Changeset.put_change(:has_filter?, false)
    chan
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_embed(:settings, chg)
    |> Repo.update!
  end

  @spec gib_slug(String.t) :: {:ok, String.t}
  def gib_slug(channel) when is_binary(channel) do
    Logger.debug("Channel: " <> channel)
    [slug] = Repo.all from c in Chan, where: c.name == ^channel,
                                      select: c.slug
    {:ok, slug}
  end

  def create_chan(%{name: chan_name, slug: slug}) do
    chan = Chan.register_changeset(%Chan{}, %{name: String.downcase(chan_name), slug: slug})
    Chan
    |> Repo.get_by(name: String.downcase(chan_name)) || Repo.insert(chan)
    |> pack
  end

  defp pack({:error, x}), do: {:error, x}
  defp pack({:ok, x}),    do: {:ok, x}
  defp pack(x),           do: {:ok, x}
end
