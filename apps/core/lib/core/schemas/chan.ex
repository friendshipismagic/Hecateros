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
      field :has_tag_filter?, :boolean
      field :has_url_filter?, :boolean
      field :url_filters, {:array, :string}
      field :tag_filters, {:array, :string}
    end
    many_to_many :admins, Admin,
                  join_through: "chan_admins"

    has_many :links, Link

    timestamps()
  end

  @type t :: %__MODULE__{name: String.t, slug: String.t, settings: %Core.Chan.Settings{}}

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
    |> put_change(:settings, %Chan.Settings{has_tag_filter?: false, has_url_filter?: true,
                                            url_filters: [], tag_filters: []})
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


  ## Tag Filters ##

  @spec add_tag_filters(t(), MapSet.t(String.t)) :: Ecto.Changeset.t | no_return
  def add_tag_filters(%Chan{}=chan, tags) do
    chg = if chan.settings.tag_filters == nil do
            Ecto.Changeset.change(chan.settings) |> Ecto.Changeset.put_change(:tag_filters, tags)
          else
            newtags = MapSet.union(tags, MapSet.new(chan.settings.tag_filters))
            Ecto.Changeset.change(chan.settings) |> Ecto.Changeset.put_change(:tag_filters, newtags)
          end

    chan
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_embed(:settings, chg)
    |> Repo.update!
  end

  @spec delete_tag_filters(t(), MapSet.t(String.t)) :: Ecto.Changeset.t | no_return
  def delete_tag_filters(%Chan{}=chan, tags) do
    chg = if chan.settings.tag_filters == nil do
            Ecto.Changeset.change(chan.settings) |> Ecto.Changeset.put_change(:tag_filters, [])
          else
            newtags = MapSet.difference(MapSet.new(chan.settings.tag_filters), tags)
            Ecto.Changeset.change(chan.settings) |> Ecto.Changeset.put_change(:tag_filters, newtags)
          end

    chan
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_embed(:settings, chg)
    |> Repo.update!
  end

  @doc "Take a `%Core.Chan{}` struct, or just its name, and flick the switch for the filter feature."
  def switch_tag_filters(:on, chan) when is_binary(chan) do
    Chan
    |> Repo.get_by(name: chan)
    |> turn_tag_filter(true)
  end

  def switch_tag_filters(:off, chan) when is_binary(chan) do
    Chan
    |> Repo.get_by(name: chan)
    |> turn_tag_filter(false)
  end

  defp turn_tag_filter(%Chan{}=chan, bool) do
    chg = Ecto.Changeset.change(chan.settings) |> Ecto.Changeset.put_change(:has_tag_filter?, bool)
    chan
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_embed(:settings, chg)
    |> Repo.update!
  end

  ## URL Filters ##

  @spec add_url_filter(t(), MapSet.t(String.t)) :: Ecto.Changeset.t | no_return
  def add_url_filter(%Chan{}=chan, urls) do
    chg = if chan.settings.url_filters == nil do
            Ecto.Changeset.change(chan.settings) |> Ecto.Changeset.put_change(:url_filters, urls)
          else
            newurls = MapSet.union(urls, MapSet.new(chan.settings.url_filters))
            Ecto.Changeset.change(chan.settings) |> Ecto.Changeset.put_change(:url_filters, newurls)
          end

    chan
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_embed(:settings, chg)
    |> Repo.update!
  end

  def switch_url_filters(:on, chan) when is_binary(chan) do
    Chan
    |> Repo.get_by(name: chan)
    |> turn_url_filter(true)
  end

  def switch_url_filters(:off, chan) when is_binary(chan) do
    Chan
    |> Repo.get_by(name: chan)
    |> turn_url_filter(false)
  end

  defp turn_url_filter(%Chan{}=chan, bool) do
    chg = Ecto.Changeset.change(chan.settings) |> Ecto.Changeset.put_change(:has_url_filter?, bool)
    chan
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_embed(:settings, chg)
    |> Repo.update!
  end

  ## Misc ##

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
