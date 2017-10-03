defmodule Tai.Poloniex.Adapter do
  def balance_btc(symbol) do
    case Poloniex.Trading.return_complete_balances(:all) do
      {:ok, completeBalances} ->
        {:ok, completeBalances[symbol]["btcValue"]}
    end
  end
end
