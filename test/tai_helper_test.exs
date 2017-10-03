defmodule TaiHelperTest do
  use ExUnit.Case
  doctest TaiHelper

  test "returns the Bitcoin balance across all accounts" do
    status = TaiHelper.status()

    assert status =~ "0.15 BTC"
  end
end
