defmodule Tai.ExchangeAdapters.OkEx.OrderBookFeed do
  @moduledoc """
  WebSocket order book feed adapter for OkEx

  https://www.okcoin.com/ws_request.html
  """

  use Tai.Exchanges.OrderBookFeed

  require Logger

  alias Tai.{Exchanges.OrderBookFeed}

  @doc """
  Secure production OkEx WebSocket url
  """
  def default_url, do: "wss://real.okcoin.com:10440/websocket"

  @doc """
  """
  def subscribe_to_order_books(name, []), do: :ok
  def subscribe_to_order_books(name, [symbol | tail]) do
    Logger.info "========== OkEx subscribe_to_order_books"
    [
      name: name,
      msg: %{
        event: "addChannel",
        # channel: "ok_sub_spot_btc_usd_depth_20",
        # channel: "ok_sub_spot_btc_usd_depth",
        channel: "ok_sub_spot_ltc_btc_depth",
        # binary: "1"
      }
    ]
    |> send_msg

    # "[{'event':'addChannel','channel':'ok_btcusd_ticker'},{'event':'addChannel','channel':'ok_btcusd_depth'},{'event':'addChannel','channel':'ok_btcusd_trades'}]"

    subscribe_to_order_books(name, tail)
  end

  @doc """
  Log the websocket version in debug
  """
  def handle_msg(%{"event" => "info", "version" => version}, feed_id) do
    Logger.debug "[#{feed_id |> OrderBookFeed.to_name}] connected to websocket version: #{inspect version}"
  end
  # @doc """
  # TODO: Need to keep track of channel ids and the pairs so they can be linked when new messages are received
  # """
  # def handle_msg(
  #   %{
  #     "chanId" => channel_id,
  #     "channel" => channel,
  #     "event" => "subscribed",
  #     "freq" => frequency,
  #     "len" => length,
  #     "pair" => pair,
  #     "prec" => precision
  #   },
  #   feed_id
  # ) do
  #   Logger.info "--- subscribed to binance channel - pair: #{inspect pair}"
  # end
  @doc """
  """
  def handle_msg([channel_id, "hb"], feed_id) do
    Logger.debug "[#{feed_id |> OrderBookFeed.to_name}] heartbeat"
  end
  @doc """
  """
  def handle_msg([channel_id, snapshot], feed_id) do
    Logger.warn "[#{feed_id |> OrderBookFeed.to_name}] snapshot: #{inspect snapshot}"

    # [feed_id: feed_id, symbol: Product.to_symbol(product_id)]
    # |> OrderBook.to_name
    # |> OrderBook.replace(
    #   bids: bids |> Snapshot.normalize,
    #   asks: asks |> Snapshot.normalize
    # )
  end
  @doc """
  Log a warning message when the WebSocket receives a message that is not explicitly handled
  """
  def handle_msg(unhandled_msg, feed_id) do
    Logger.warn "[#{feed_id |> OrderBookFeed.to_name}] unhandled message: #{inspect unhandled_msg}"
  end

  defp send_msg(name: name, msg: msg) do
    name
    |> WebSockex.send_frame({:text, JSON.encode!(msg)})
  end
end
