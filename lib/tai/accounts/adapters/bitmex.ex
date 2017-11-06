defmodule Tai.Accounts.Adapters.Bitmex do
  use GenServer

  def start_link({id, api_key: api_key, secret: secret}) do
    GenServer.start_link(
      __MODULE__,
      [api_key: api_key, secret: secret],
      name: id |> Tai.Accounts.Adapter.to_pid
    )
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:balance, _from, state) do
    # "https://www.bitmex.com/api/v1/user/margin?currency=XBt"

    # {:ok, bitmex} = Bitmex.Client.start_link([api_key: "abc123", secret: "secret"])


    Bitmex.margin(:my_pid)

    {:reply, 100.1, state}
  end

  def balance(id) do
    GenServer.call(id |> Tai.Accounts.Adapter.to_pid, :balance)
  end
end
