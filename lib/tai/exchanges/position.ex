defmodule Tai.Exchanges.Position do
  use GenServer

  def start_link(feed_id: feed_id, symbol: symbol) do
    GenServer.start_link(
      __MODULE__,
      :ok,
      name: [feed_id: feed_id, symbol: symbol] |> to_name
    )
  end

  def to_name(feed_id: feed_id, symbol: symbol) do
    :"#{__MODULE__}_#{feed_id}_#{symbol}"
  end

  def init(:ok) do
    {:ok, :ok}
  end
end
