defmodule Tai.Currency do
  def add(symbol, balance_a, balance_b) do
    case symbol |> adapter do
      {:ok, currency} -> currency.add(balance_a, balance_b)
      {:error, error} -> {:error, error}
    end
  end

  defp adapter(symbol) do
    case symbol do
      :btc -> {:ok, Tai.Currencies.Bitcoin}
      :ltc -> {:ok, Tai.Currencies.Litecoin}
      _ -> {:error, :unknown_symbol, symbol}
    end
  end
end
