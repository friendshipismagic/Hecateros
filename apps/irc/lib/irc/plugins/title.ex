defmodule IRC.Plugins.Title do
  require Logger

  @headers [{"Accept", "text/html"}]

  def get_title(url) do
    with {:ok, new_url} <- check(url),
         {:ok, body}    <- fetch(new_url),
         {:ok, title}   <- parse(body) do
           {:ok, title}
    else
      error -> error
    end
  end

  def check(url, redirects \\ 0)
  def check(url, 3), do: {:error, "Too many redirections"}
  def check(url, redirects) do
    r = HTTPoison.head!(url, @headers)
    case moved_in(r) do
      {:moved, new_url} -> check(new_url, redirects + 1)
      {:stay,  url}     ->
        [{"Content-Type", content}] = Enum.filter r.headers, fn {k,_} -> k == "Content-Type" end
        if content =~ "text/html" do
          {:ok, url}
        else
          {:error, "Not an HTML page"}
        end
    end
  end

  def moved_in(%HTTPoison.Response{}=r) do
    if r.status_code in [301,302] do
      [{"Location", url}] = Enum.filter(r.headers, fn {k,_} -> k == "Location" end)
      {:moved, url}
    else
      {:stay, r.request_url}
    end
  end

  def fetch(url) do
    response = HTTPoison.get!(url, @headers)
    {:ok, response.body}
  end

  def parse(body) do
    [title] = Regex.run(~r/<title>(.*?)<\/title>/, body, capture: :all_but_first)
    {:ok, title}
  end
end
