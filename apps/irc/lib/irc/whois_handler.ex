defmodule IRC.WhoisHandler do

  alias IRC.State
  require Logger
  use Agent

  def start_link(%State{}=state) do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end
end
