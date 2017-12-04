defmodule Tai.History do
  alias Tai.Candle
  alias Tai.Repo

  def candles(
    exchange: exchange,
    symbol: symbol,
    date_from: date_from,
    date_to: date_to,
    period: period
  ) do
    Tai.Queries.Candles.where(
      exchange: exchange,
      symbol: symbol,
      period: period,
      date_from: date_from,
      date_to: date_to
    )
    |> Enum.map(fn(candle) ->
      %Candle{
        open_at: candle.open_at,
        period: candle.period,
        open: candle.open,
        high: candle.high,
        low: candle.low,
        close: candle.close
      }
    end)
  end

  def save(candles) do
    candles
    |> Enum.each(fn(candle) ->
      candle
      |> Repo.insert
    end)
  end
end
