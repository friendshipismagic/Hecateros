defmodule IRC.Plugins.Title do
  require Logger


  @headers [{"Accept", "text/html"}]

  def get_title(url) do
    with {:ok, body}    <- fetch(url),
         {:ok, title}   <- parse(body) do
           {:ok, title}
    else
      error -> error
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
