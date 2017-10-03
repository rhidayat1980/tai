defmodule Tai.Gemini.MarketData do
  @moduledoc """
  Documentation for Tai.Gemini.MarketData.
  """

  use WebSockex
  require Logger

  def start_link(symbol, order_book) when is_bitstring(symbol) do
    url = "wss://api.gemini.com/v1/marketdata/#{symbol}"

    WebSockex.start_link(
      url,
      __MODULE__,
      %{symbol: symbol, order_book: order_book}
    )
  end

  def handle_frame({:text, msg}, state) do
    Logger.debug "[#{__MODULE__}:#{state.symbol}] #{msg}"

    case JSON.decode(msg) do
      {:ok, %{"type" => "update", "socket_sequence" => _socket_sequence, "events" => events}} ->
        handle_events(state.order_book, DateTime.utc_now(), events)
        {:ok, state}
      {:ok, %{"type" => "update", "timestamp" => unix_timestamp, "events" => events}} ->
        handle_events(state.order_book, DateTime.from_unix(unix_timestamp), events)
        {:ok, state}
      {:ok, %{"type" => "heartbeat"}} ->
        {:ok, state}
      _ ->
        {:error, state}
    end
  end

  defp handle_events(order_book, timestamp, events) do
    Enum.each(events, &handle_event(order_book, timestamp, &1))
  end

  defp handle_event(
    order_book,
    timestamp,
    %{"type" => "change", "price" => price, "remaining" => remaining, "side" => side}
  ) when side in ["bid", "ask"] do
    {price, _} = Float.parse(price)
    {remaining, _} = Float.parse(remaining)

    Tai.OrderBook.put(
      order_book,
      String.to_atom(side),
      price,
      remaining,
      timestamp
    )
  end

  # %{"type" => "trade", "amount" => amount, "makerSide" => maker_side, "price" => price, "tid" => trade_id}
  defp handle_event(
    order_book,
    timestamp,
    %{"type" => "trade"}
  ) do
    # Logger.info "TRADE!!!"
  end

  defp handle_event(
    order_book,
    timestamp,
    %{"type" => "auction"}
  ) do
    # Logger.info "AUCTION!!!"
  end
end
