defmodule Tai.Exchanges.OrderFeedSupervisor do
  use Supervisor

  alias Tai.Exchanges.Config

  def start_link(feed_id) do
    Supervisor.start_link(__MODULE__, feed_id, name: feed_id |> to_name)
  end

  def init(feed_id) do
    feed_id
    |> to_children
    |> Supervisor.init(strategy: :one_for_all)
  end

  def to_name(feed_id) do
    :"#{__MODULE__}_#{feed_id}"
  end

  defp to_children(feed_id) do
    position_child_specs(feed_id)
    |> Enum.concat(
      [feed_id |> feed_child_spec]
    )
  end

  defp position_child_specs(feed_id) do
    feed_id
    |> Config.order_feed_symbols
    |> Enum.map(
      &Supervisor.child_spec(
        {Tai.Exchanges.Position, feed_id: feed_id, symbol: &1},
        id: "#{Tai.Exchanges.Position}_#{feed_id}_#{&1}"
      )
    )
  end

  defp feed_child_spec(feed_id) do
    %{
      id: feed_id |> Tai.Exchanges.OrderFeed.to_name,
      start: {feed_id |> Config.order_feed_adapter, :start_link, [feed_id]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
