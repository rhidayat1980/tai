defmodule Tai.Exchanges.OrderFeedsSupervisor do
  use Supervisor

  alias Tai.Exchanges.Config

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    # [
    #   # Supervisor.child_spec(
    #   #   {Tai.ExchangeAdapters.Gdax.OrderFeed, ["the_feed_id"]},
    #   #   id: "the_feed_id"
    #   # )
    #   %{
    #     id: Tai.ExchangeAdapters.Gdax.OrderFeed,
    #     start: {Tai.ExchangeAdapters.Gdax.OrderFeed, :start_link, [:gdax]}
    #   }
    # ]
    Config.order_feed_ids
    # []
    # |> Enum.map(fn feed_id ->
    #   %{
    #     id: "#{Tai.ExchangeAdapters.Gdax.OrderFeed}_#{feed_id}",
    #     start: {Tai.ExchangeAdapters.Gdax.OrderFeed, :start_link, [feed_id]}
    #   }
    # end)
    |> Enum.map(
      &Supervisor.child_spec(
        {Tai.Exchanges.OrderFeedSupervisor, &1},
        id: "#{Tai.Exchanges.OrderFeedSupervisor}_#{&1}"
      )
    )
    |> Supervisor.init(strategy: :one_for_one)
  end
end
