defmodule Tai.ExchangeAdapters.Poloniex.Account.AllBalances do
  @moduledoc """
  Fetch and normalize all balances on the Poloniex account
  """

  alias Tai.{CredentialError, TimeoutError}

  def fetch do
    ExPoloniex.Trading.return_complete_balances()
    |> normalize_accounts
  end

  defp normalize_accounts({:ok, raw_accounts}) do
    accounts =
      raw_accounts
      |> Enum.reduce(%{}, &normalize_account/2)

    {:ok, accounts}
  end

  defp normalize_accounts({:error, %ExPoloniex.AuthenticationError{} = reason}) do
    {:error, %CredentialError{reason: reason}}
  end

  defp normalize_accounts({:error, %HTTPoison.Error{reason: "timeout"}}) do
    {:error, %TimeoutError{reason: "network request timed out"}}
  end

  defp normalize_account(
         {
           raw_currency,
           %{"available" => raw_available, "onOrders" => raw_on_orders}
         },
         acc
       ) do
    with symbol <- raw_currency |> String.downcase() |> String.to_atom(),
         detail <- Tai.Exchanges.BalanceDetail.new(raw_available, raw_on_orders) do
      Map.put(acc, symbol, detail)
    end
  end
end
