defmodule Tai.Candle do
  use Ecto.Schema

  schema "candles" do
    field :exchange,  :string
    field :open_at,   :naive_datetime
    field :period,    :string
    field :open,      :decimal
    field :high,      :decimal
    field :low,       :decimal
    field :close,     :decimal
  end
end

