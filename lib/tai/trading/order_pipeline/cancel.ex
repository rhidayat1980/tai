defmodule Tai.Trading.OrderPipeline.Cancel do
  require Logger

  def call(order) do
    with previous_order <- Tai.Trading.OrderStore.find(order.client_id),
         updated_order <-
           Tai.Trading.OrderStore.update(
             previous_order.client_id,
             status: Tai.Trading.OrderStatus.cancelling()
           ),
         :ok <- Logger.info("order cancelling - client_id: #{updated_order.client_id}"),
         Tai.Trading.Order.updated_callback(previous_order, updated_order) do
      {:ok, _pid} =
        Task.start_link(fn ->
          updated_order.account_id
          |> Tai.Exchanges.Account.cancel_order(updated_order.server_id)
          |> parse_cancel_order_response(updated_order)
        end)

      {:ok, updated_order}
    end
  end

  defp parse_cancel_order_response({:ok, _order_id}, previous_order) do
    updated_order =
      Tai.Trading.OrderStore.update(
        previous_order.client_id,
        status: Tai.Trading.OrderStatus.cancelled()
      )

    Logger.info("order cancelled - client_id: #{updated_order.client_id}")

    Tai.Trading.Order.updated_callback(previous_order, updated_order)
  end
end
