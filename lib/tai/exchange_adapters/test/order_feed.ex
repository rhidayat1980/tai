defmodule Tai.ExchangeAdapters.Test.OrderFeed do
  use Tai.Exchanges.OrderFeed

  def url, do: "ws://localhost:#{EchoBoy.Config.port}/ws"

  def subscribe_to_orders(_name, _symbols), do: :ok

  def handle_msg(_msg, _feed_id), do: nil
end
