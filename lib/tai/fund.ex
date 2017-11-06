defmodule Tai.Fund do
  use GenServer
  alias Tai.Currency
  alias Tai.Accounts
  alias Tai.Settings

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:balance, _from, state) do
    balance = account_balances()
              |> Currency.sum(:btc)

    {:reply, balance, state}
  end

  defp account_balances do
    Settings.account_ids
    |> Enum.map(fn(id) -> Accounts.Adapter.balance(id) end)
  end

  def balance do
    GenServer.call(__MODULE__, :balance)
  end
end
