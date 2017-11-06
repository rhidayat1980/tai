defmodule Tai.Settings do
  def accounts do
    Application.get_env(:tai, :accounts)
  end

  def account_ids do
    accounts()
    |> Enum.map(fn {id, _config} -> id end)
  end

  def account_adapters do
    Enum.reduce(accounts(), %{}, fn ({id, [adapter, _config]}, acc) ->
      Map.put(acc, id, adapter)
    end)
  end
end
