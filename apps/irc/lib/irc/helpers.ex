defmodule IRC.Helpers do

  use Tesla
  require Logger

  plug Tesla.Middleware.Headers, %{"Accept" => "text/html"}
  plug Tesla.Middleware.Opts, [recv_timeout: :infinity]
  plug Tesla.Middleware.FollowRedirects, max_redirects: 10

  def get_info(url) do
    {:ok, body}  = fetch(url)
    {:ok, title} = get_title(body)

    case get_desc(body) do
      {:ok, desc} ->
        {:ok, title, desc}
      {:error, :nodesc} ->
        # Récupérer la meta-description
        {:ok, title, url}
    end
  end

  def get_title(body) do
    og = OpenGraphExtended.parse(body)
    if og.title do
      {:ok, og.title}
    else
      parse_title(body)
    end
  end

  defp fetch(url) do
    %Tesla.Env{status: 200, body: body} = get url
    {:ok, body}
  end

  defp parse_title(body) do
    [title] = Regex.run(~r/<title>(.*?)<\/title>/, body, capture: :all_but_first)
    {:ok, title}
  end

  defp get_desc(body) do
    og = OpenGraphExtended.parse(body)

    if og.description do
      {:ok, og.description}
    else
      {:error, :nodesc}
    end
  end

  @spec check_auth(%ExIRC.Whois{}) :: {:ok, :authed, String.t} | {:error, :unauthed}
  def check_auth(user) do
    if user.account_name do
      {:ok, :authed}
    else
      {:error, :unauthed}
    end
  end

  def get_whois(nick) do
    :timer.sleep(1000)
    Agent.get_and_update(IRC.WhoisHandler, fn x -> Map.pop(x, nick) end)
  end
end
