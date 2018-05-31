defmodule Tai.Trading.OrderPipeline.Send do
  require Logger

  def call(%Tai.Trading.Order{side: :buy, type: :limit} = order) do
    Task.start_link(fn ->
      order
      |> Tai.Exchanges.Account.buy_limit()
      |> parse_order_response(order)
    end)
  end

  def call(%Tai.Trading.Order{side: :sell, type: :limit} = order) do
    Task.start_link(fn ->
      order
      |> Tai.Exchanges.Account.sell_limit()
      |> parse_order_response(order)
    end)
  end

  def call(%Tai.Trading.Order{} = order) do
    Logger.warn(
      "order error - client_id: #{order.client_id}, cannot send unhandled order type '#{
        order.side
      } #{order.type}'"
    )
  end

  defp parse_order_response(
         {:ok, %Tai.Trading.OrderResponse{status: :expired}},
         previous_order
       ) do
    updated_order =
      Tai.Trading.OrderStore.update(
        previous_order.client_id,
        status: Tai.Trading.OrderStatus.expired()
      )

    Tai.Trading.Order.updated_callback(previous_order, updated_order)
  end

  defp parse_order_response(
         {:ok, %Tai.Trading.OrderResponse{status: :filled, executed_size: executed_size}},
         previous_order
       ) do
    Logger.warn(fn -> "order filled - client_id: #{previous_order.client_id}" end)

    updated_order =
      Tai.Trading.OrderStore.update(
        previous_order.client_id,
        status: Tai.Trading.OrderStatus.filled(),
        executed_size: executed_size
      )

    Tai.Trading.Order.updated_callback(previous_order, updated_order)
  end

  defp parse_order_response(
         {:ok, %Tai.Trading.OrderResponse{status: :pending, id: server_id}},
         previous_order
       ) do
    Logger.info(fn -> "order pending - client_id: #{previous_order.client_id}" end)

    updated_order =
      Tai.Trading.OrderStore.update(
        previous_order.client_id,
        status: Tai.Trading.OrderStatus.pending(),
        server_id: server_id
      )

    Tai.Trading.Order.updated_callback(previous_order, updated_order)
  end

  defp parse_order_response({:error, reason}, previous_order) do
    Logger.warn(fn ->
      "order error - client_id: #{previous_order.client_id}, '#{inspect(reason)}'"
    end)

    updated_order =
      Tai.Trading.OrderStore.update(
        previous_order.client_id,
        status: Tai.Trading.OrderStatus.error(),
        error_reason: reason
      )

    Tai.Trading.Order.updated_callback(previous_order, updated_order)
  end
end
