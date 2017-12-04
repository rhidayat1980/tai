defmodule Tai.CommandsHelper do
  def help do
    IO.puts """
    * status
    * quotes exchange(:gdax), symbol(:btcusd)
    * buy_limit exchange(:gdax), symbol(:btcusd), price(101.12), size(1.2)
    * sell_limit exchange(:gdax), symbol(:btcusd), price(101.12), size(1.2)
    * order_status exchange(:gdax), order_id("f1bb2fa3-6218-45be-8691-21b98157f25a")
    * cancel_order exchange(:gdax), order_id("f1bb2fa3-6218-45be-8691-21b98157f25a")
    * history exchange(:gdax), symbol(:btcusd), date_from("2016-01-01"), date_to("2017-01-01"), period("1d")
    * history_download exchange(:gdax), symbol(:btcusd), date_from("2016-01-01"), date_to("2017-01-01")
    """
  end

  def status do
    IO.puts "#{Tai.Fund.balance} USD"
  end

  def quotes(exchange, symbol) do
    exchange
    |> Tai.Exchange.quotes(symbol)
    |> case do
      {:ok, bid, ask} ->
        IO.puts """
        #{ask.price}/#{ask.size} [#{ask.age}s]
        ---
        #{bid.price}/#{bid.size} [#{bid.age}s]
        """
      {:error, message} ->
        IO.puts "error: #{message}"
    end
  end

  def buy_limit(exchange, symbol, price, size) do
    exchange
    |> Tai.Exchange.buy_limit(symbol, price, size)
    |> case do
      {:ok, order_response} ->
        IO.puts "create order success - id: #{order_response.id}, status: #{order_response.status}"
      {:error, message} ->
        IO.puts "create order failure - #{message}"
    end
  end

  def sell_limit(exchange, symbol, price, size) do
    exchange
    |> Tai.Exchange.sell_limit(symbol, price, size)
    |> case do
      {:ok, order_response} ->
        IO.puts "create order success - id: #{order_response.id}, status: #{order_response.status}"
      {:error, message} ->
        IO.puts "create order failure - #{message}"
    end
  end

  def order_status(exchange, order_id) do
    exchange
    |> Tai.Exchange.order_status(order_id)
    |> case do
      {:ok, status} ->
        IO.puts "status: #{status}"
      {:error, message} ->
        IO.puts "error: #{message}"
    end
  end

  def cancel_order(exchange, order_id) do
    exchange
    |> Tai.Exchange.cancel_order(order_id)
    |> case do
      {:ok, _canceled_order_id} ->
        IO.puts "cancel order success"
      {:error, message} ->
        IO.puts "error: #{message}"
    end
  end

  def strategy(name) do
    name
    |> Tai.Strategy.info
    |> case do
      {:ok, info} ->
        IO.puts "started: #{info.started_at}"
    end
  end

  def history(exchange, symbol, date_from_str, date_to_str, period) do
    {:ok, date_from} = Timex.parse(date_from_str, "{YYYY}-{0M}-{0D}")
    {:ok, date_to} = Timex.parse(date_to_str, "{YYYY}-{0M}-{0D}")


    Tai.History.candles(
      exchange: exchange,
      symbol: symbol,
      date_from: date_from,
      date_to: date_to,
      period: period
    )
    |> Enum.each(fn(candle) ->
      IO.puts "#{candle.open_at} o:#{candle.open} h:#{candle.high} l:#{candle.low} c:#{candle.close}"
    end)
  end

  def history_download(exchange, symbol, date_from_str, date_to_str) do
    IO.puts "downloading..."

    {:ok, date_from} = Timex.parse(date_from_str, "{YYYY}-{0M}-{0D}")
    {:ok, date_to} = Timex.parse(date_to_str, "{YYYY}-{0M}-{0D}")

    Tai.Exchange.history(
      name: exchange,
      symbol: symbol,
      date_from: date_from,
      date_to: date_to
    )
    |> Tai.History.save

    IO.puts "finished!"
  end
end
