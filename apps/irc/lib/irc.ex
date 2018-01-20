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
              ]
  end

  defmodule Event do
    defstruct [:chan,
               :client,
               :message,
               :sender,
               :tags,
               :title,
               :url
              ]
  end
end
