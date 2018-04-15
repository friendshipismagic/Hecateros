defmodule ChanTest do
  use ExUnit.Case

  alias Core.Chan
  alias Core.Repo

  setup_all do
    c1 = Chan.create_chan(%{name: "#Ekta-bots", slug: "343eg4"})
    c2 = Chan.create_chan(%{name: "#Ekta", slug: "efon3"})
    Chan.add_url_filters(c1, MapSet.new(["example.org", "lol.com"]))
    Chan.add_url_filters(c2, MapSet.new(["foobar.com", "rezel.net", "google.cloud"]))
    c1 = Repo.get(Chan, 1)
    c2 = Repo.get(Chan, 2)
    {:ok, %{chan1: c1, chan2: c2}}
  end


  test "Gib slug for #ekta-bots", _ do
    assert {:ok, "343eg4"} == Chan.gib_slug("#ekta-bots")
  end

  test "Delete URL filters for a channel", %{chan1: c} do
    chan = Chan.delete_url_filters(c, MapSet.new(["lol.com"]))
    assert false == Enum.any?(chan.settings.url_filters, fn d -> d == "lol.com" end)
  end

  test "Replace URL filters", %{chan2: c} do
    Chan.replace_url_filters(c, MapSet.new())
    chan = Repo.get(Chan, 2)
    assert [] == chan.settings.url_filters
  end
end
