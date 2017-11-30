defmodule IRC.Plugins.Title do
  require Logger

  @headers [{"Accept", "text/html"}]

  def get_title(url) do
    with :ok          <- check(url),
         {:ok, body}  <- fetch(url),
         {:ok, title} <- parse(body) do
           {:ok, title}
    else
      error -> error
    end
  end
  
  def check(url) do
    url = url
    response = HTTPoison.head!(url, @headers)
    [{"Content-Type", content}] = Enum.filter response.headers, fn {name, _value} -> name == "Content-Type" end
    if content =~ "text/html" do
      :ok
    else
      {:error, "Not an HTML page"}
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
