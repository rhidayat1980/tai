defmodule Tai.Account do
  def balance_btc(:poloniex, symbol) do
    # Tai.Poloniex.Adapter.balance_btc(symbol)
    0.1
  end

  def balance_btc(:bitmex, _symbol) do
    0.05
  end
end
