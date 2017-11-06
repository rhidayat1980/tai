defmodule Tai.Accounts.AdapterTest do
  use ExUnit.Case
  doctest Tai.Accounts.Adapter

  test "to_pid returns an atom of the module name and adapter account id" do
    assert Tai.Accounts.Adapter.to_pid(:test_account_a) == "#{Tai.Accounts.Adapters.Test}_test_account_a" |> String.to_atom
  end
end
