defmodule IRC.Auth do
  @moduledoc false

  def check_auth(nickname) do
    client = GenServer.call(IRC.ConnectionHandler, :client)
    user = ExIrc.Client.whois!(client, nickname)
    if user.account_name, do: {:ok, :authed}, else: {:error, :unauthed}
  end

    defdelegate check_admin(account_name, channel), to: Core.Users
end
