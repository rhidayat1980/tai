defmodule Tai.Accounts.Adapter do
  alias Tai.Settings

  def to_pid(id) do
    adapter = id |> find
    "#{adapter}_#{id}" |> String.to_atom
  end

  def balance(id) do
    adapter = id |> find
    adapter.balance(id)
  end

  defp find(id) do
    Settings.account_adapters[id]
  end
end
