defmodule Tai.Repo.Migrations.CreateCandles do
  use Ecto.Migration

  def change do
    create table(:candles) do
      add :exchange,  :string, null: false
      add :open_at,   :naive_datetime, null: false
      add :period,    :string, null: false
      add :open,      :decimal, null: false
      add :high,      :decimal, null: false
      add :low,       :decimal, null: false
      add :close,     :decimal, null: false
    end
  end
end
