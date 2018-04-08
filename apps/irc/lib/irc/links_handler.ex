defmodule IRC.LinksHandler do

  alias IRC.{State, Helpers}
  alias Core.Chan
  alias Core.Repo
  use GenServer
  require Logger

  def start_link(%State{}=state) do
    GenServer.start_link(__MODULE__, state.client, name: __MODULE__)
  end

  def init(client) do
    ExIRC.Client.add_handler(client, self())
    {:ok, client}
  end

  def handle_info({:received, message, _sender, chan}, state) do
    message
    |> parse(chan)
    |> insert

    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def parse(message, chan) do
    channel = Repo.get_by(Chan, name: String.downcase(chan))
    with {:ok, url}         <- parse_url(message),
         {:ok, taglist}     <- parse_tags(message),
         {:ok, :ok}         <- check_filters(url, taglist, channel),
         {:ok, title, desc} <- Helpers.get_info(url) do
            foreign_tags = MapSet.new(taglist)
            chan_tags    = MapSet.new(channel.settings.tag_filters)
            newtaglist = MapSet.intersection(chan_tags, foreign_tags)
            {:ok, %{tags: newtaglist, url: url, chan: channel.name, title: title, description: desc}}
    else
      e -> e
    end
  end

  def insert({:ok, %{}=map}) do
    Core.insert_link(map)
  end
  def insert(_), do: nil

  def parse_tags(message) do
    tags_regex = ~r/(?<=\#)(.*?)(?=\#)/
    case Regex.run(tags_regex, message, capture: :first) do
      nil    -> {:error, :notag}
      [tags] ->
        taglist =
          tags
          |> String.replace(" ", "")
          |> String.split(",")
          |> Enum.map(fn tag -> String.downcase tag end)

        {:ok, taglist}
    end
  end


  def parse_url(message) do
    url_regex = ~r/((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)/iu
    case Regex.run(url_regex, message, capture: :first) do
      nil   -> {:error, :nolink}
      [url] -> url |> String.split("#") |> hd |> validate_url
    end
  end

  defp validate_url(url) do
    case URI.parse(url) do
      %URI{scheme: nil} -> {:error, :invalid}
      %URI{host: nil, path: nil} -> {:error, :invalid}
      _ -> {:ok, url}
    end
  end

  def check_filters(url, taglist, channel) do
    t = with true <- channel.settings.has_tag_filter?,
             :ok  <- is_in_filters([tags: taglist, chan: channel]) do
              :ok
        else
          :filtered -> :filtered
          false     -> :ok
        end

    u = with true <- channel.settings.has_url_filter?,
             :ok  <- is_in_filters([url: url, chan: channel]) do
               :ok
        else
          :filtered -> :filtered
          false     -> :ok
        end
    {t, u}
  end

  def is_in_filters([url: url, chan: channel]) do
    if URI.parse(url).host in channel.settings.url_filters do
      :filtered
    else
      :ok
    end
  end

  def is_in_filters([tags: tags, chan: chan]) do
    foreign_tags = MapSet.new(tags)
    chan_tags    = MapSet.new(chan.settings.tag_filters)
    case MapSet.intersection(chan_tags, foreign_tags) do
      %MapSet{} -> :filtered
      _         -> :ok
    end
  end
end
