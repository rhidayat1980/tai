defmodule TaiHelper do
  def status do
    IO.puts "#{Tai.Accounts.balance_btc(:btc)} BTC"
    # IO.puts "#{Tai.Accounts.balance_btc(:eth)} ETH"
  end
end
