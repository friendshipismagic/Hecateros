defmodule Web.ChanView do
  use Web, :view

  def format_date(inserted) do
    case Timex.format(inserted, "{YYYY}-{0M}-{0D} at {h24}:{m}") do
      {:ok, new_date} -> new_date
      _               -> ""
    end
  end
end
