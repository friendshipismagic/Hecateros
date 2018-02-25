defmodule IRC.LinksHandler do

  alias IRC.{State, Helpers}
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
    with {:ok, url}         <- parse_url(message),
         {:ok, taglist}     <- parse_tags(message),
         {:ok, title, desc} <- Helpers.get_info(url),
         channel        =  String.downcase(chan) do
           {:ok, %{tags: taglist, url: url, chan: channel, title: title, description: desc}}
    end
  end

  def insert({:error, _}), do: nil
  def insert({:ok, map}) do
    Core.insert_link(map)
  end

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
end
