defmodule IRC.Plugins.Links do
  use GenServer
  require Logger
  alias IRC.{Plugins, EventHandler, Event}

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    EventHandler.subscribe
  end

  def handle_cast({:irc, %Event{}=message}, state) do
    message
    |> parse
    |> insert
    {:noreply, state}
  end

  def parse(struct) do
    with {:ok, url}     <- parse_url(struct.message),
         {:ok, taglist} <- parse_tags(struct.message),
         {:ok, title}   <- Plugins.Title.get_title(url),
         chan           <- String.downcase(struct.chan) do
           {:ok, %{struct|tags: taglist, url: url,chan: chan, title: title}}
    else
      {:error, :nolink} -> :error
      {:error, :notag}  -> :error
      error -> 
        Logger.debug (inspect error)
        :error
    end
  end

  def insert(:error), do: :error
  def insert({:ok, struct}) do
    Logger.info(inspect struct)
    Core.insert_link struct
  end

  ## Backend API ##

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
