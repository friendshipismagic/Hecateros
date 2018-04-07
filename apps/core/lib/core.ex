defmodule Core do
  @moduledoc """
  """
  alias Core.{Chan,Repo,Link}
  require Logger
  import Ecto.Query

  defdelegate get_links(criteria, slug), to: Core.Link
  defdelegate insert_link(map),          to: Core.Link
  defdelegate create_link(attrs)         to: Core.Link

  defdelegate switch_filters(chan), to: Core.Chan
  defdelegate gib_slug(chan),       to: Core.Chan
  defdelegate create_chan(map),     do: Core.Chan

  ###########
  # Helpers #
  ###########

  # defp trace(x) do
  #   Logger.info("[TRACE] "<> inspect(x))
  #   x
  # end

  def version do
    if File.exists?(".git") do
      version = System.cmd("git", ~w(describe --always --tags HEAD)) |> elem(0) |> String.replace("\n", "")
      "Running on version #{version}"
    else
      ""
    end
  end
end
