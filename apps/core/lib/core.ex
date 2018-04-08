defmodule Core do
  @moduledoc """
  """
  alias Core.{Chan,Link}
  require Logger

  defdelegate get_links(criteria, slug), to: Link
  defdelegate insert_link(map),          to: Link
  defdelegate create_link(attrs),        to: Link

  defdelegate gib_slug(chan),       to: Chan
  defdelegate create_chan(map),     to: Chan

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
