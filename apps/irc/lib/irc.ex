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
               :tls?,
               :username,
               :pipeline
              ]
  end

  defmodule Event do
    defstruct [:message,
               :sender,
               :tags,
               :url,
               :title,
               :chan
              ]
  end
end
