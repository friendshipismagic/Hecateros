defmodule IRC do
  @moduledoc """
  Documentation for IRC.
  """

  defmodule State do
    defstruct [:client,
               :channels,
               :handlers,
               :host,
               :nick,
               :pass,
               :port,
               :name,
               :ssl?,
               :user,
               :whois,
              ]
  end
end
