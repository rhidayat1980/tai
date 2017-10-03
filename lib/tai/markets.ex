defmodule Tai.Markets do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, [name: __MODULE__])
  end

  def connect(symbol, exchange) do
    GenServer.cast(__MODULE__, {:connect, symbol, exchange})
  end

  def list_symbols do
    GenServer.call(__MODULE__, :list_symbols)
    # %{
    #   "btcusd" => ["gemini", "okcoin", "gdax", "bitfinex"]
    # }
  end

  def handle_cast(:connect, {symbol, exchange}, state) do
    {:norepy, state}
  end

  def handle_call(:list_symbols, _from, state) do
    {:reply, state, state}
  end
end
