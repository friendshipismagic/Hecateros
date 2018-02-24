defmodule IRC do
  @moduledoc """
  Documentation for IRC.
  """

  defmodule State do
    defstruct [:client,
               :channels,
               :handlers,
               :host,
               :nickname,
               :pass,
               :port,
               :realname,
               :ssl?,
               :username,
               :whois,
              ]
  end
end
