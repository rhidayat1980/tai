defmodule Tai.Accounts do
  def balance_btc(symbol) do
    Tai.Currency.add(
      symbol,
      Tai.Account.balance_btc(:bitmex, symbol),
      Tai.Account.balance_btc(:poloniex, symbol)
    )
  end
end
