defmodule Tai.Accounts.Adapters.Test do
  use GenServer

  def start_link({id, config}) do
    GenServer.start_link(
      __MODULE__,
      config,
      name: id |> Tai.Accounts.Adapter.to_pid
    )
  end

  def init(state) do
    {:ok, state}
  end

  def balance(_id) do
    0.11
  end
end
