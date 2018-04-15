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
    with {:url, url}        <- parse_url(message,  channel),
         {:tags, taglist}   <- parse_tags(message, channel),
         {:ok, title, desc} <- Helpers.get_info(url) do
            Logger.debug "Taglist: #{inspect taglist}"
            {:ok, %{tags: taglist, url: url, chan: channel.name, title: title, description: desc}}
    else
      e -> e
    end
  end

  def insert({:ok, %{}=map}) do
    Core.insert_link(map)
  end
  def insert(_), do: nil

  def parse_tags(message, channel) do
    tags_regex = ~r/(?<=\#)(.*?)(?=\#)/
    case Regex.run(tags_regex, message, capture: :first) do
      nil    -> {:error, :notag}
      [tags] ->
        taglist = tags
                  |> String.replace(" ", "")
                  |> String.split(",")
                  |> Enum.map(fn tag -> String.downcase tag end)

        if channel.settings.has_tag_filter? do
          case is_in_filters([tags: taglist, chan: channel]) do
            {:tags, taglist}     -> {:tags, taglist}
            {:error, :filtered}  -> {:error, :filtered}
          end
        else
          {:tags, taglist}
        end
    end
  end


  def parse_url(message, channel) do
    url_regex = ~r/((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)/iu
    case Regex.run(url_regex, message, capture: :first) do
      nil   -> {:error, :nolink}
      [url] -> url |> String.split("#") |> hd |> validate_url(channel)
    end
  end

  defp validate_url(url, channel) do
    case URI.parse(url) do
      %URI{scheme: nil}          -> {:error, :invalid}
      %URI{host: nil, path: nil} -> {:error, :invalid}
      _                          -> is_in_filters([url: url, chan: channel])
    end
  end

  @spec is_in_filters(keyword(String.t)) :: {:url,  URI.t } | {:tags, String.t} | {:error, :filtered}
  def is_in_filters([url: url, chan: channel]) do
    if URI.parse(url).host in channel.settings.url_filters do
      {:error, :filtered}
    else
      {:url, url}
    end
  end

  def is_in_filters([tags: tags, chan: chan]) do
    foreign_tags = MapSet.new(tags)
    chan_tags    = MapSet.new(chan.settings.tag_filters)
    case MapSet.intersection(chan_tags, foreign_tags) do
      %MapSet{} -> {:error, :filtered}
      tags      -> {:tags, tags}
    end
  end
end
