defmodule Tai.Queries.CandlesTest do
  use ExUnit.Case
  doctest Tai.Queries.Candles

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Tai.Repo)
  end

  test "returns candles for the exchange, symbol and period between the given date range" do
    {:ok, date_1} = Timex.parse("2016-01-01", "{YYYY}-{0M}-{0D}")
    {:ok, date_2} = Timex.parse("2016-01-02", "{YYYY}-{0M}-{0D}")

    exchange_candle_1 = (%Tai.Candle{
      exchange: "exchange_a",
      open_at: date_1,
      period: "1d",
      open: Decimal.new(100.0),
      high: Decimal.new(100.1),
      low: Decimal.new(99.9),
      close: Decimal.new(100.0)
    }
    |> Tai.Repo.insert!)
    exchange_candle_2 = (%Tai.Candle{
      exchange: "exchange_a",
      open_at: date_2,
      period: "1d",
      open: Decimal.new(101.0),
      high: Decimal.new(101.1),
      low: Decimal.new(98.9),
      close: Decimal.new(101.0)
    }
    |> Tai.Repo.insert!)
    other_exchange_candle = (%Tai.Candle{
      exchange: "other_exchange",
      open_at: date_2,
      period: "1d",
      open: Decimal.new(102.0),
      high: Decimal.new(102.1),
      low: Decimal.new(97.9),
      close: Decimal.new(102.0)
    }
    |> Tai.Repo.insert!)

    assert Tai.Queries.Candles.where(
      exchange: :test_exchange_a,
      symbol: :btcusd,
      period: "1d",
      date_from: date_1,
      date_to: date_2
    ) == [
      exchange_candle_1,
      exchange_candle_2
    ]
  end
end
