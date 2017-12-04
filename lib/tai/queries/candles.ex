defmodule Tai.Queries.Candles do
  import Ecto.Query
  alias Tai.Candle
  alias Tai.Repo

  def where(
    exchange: exchange,
    symbol: symbol,
    period: period,
    date_from: date_from,
    date_to: date_to
  ) do
    (from c in Candle,
    where: c.open_at >= ^date_from and c.open_at < ^Timex.shift(date_to, days: 1),
    select: c)
    |> Repo.all
  end
end
