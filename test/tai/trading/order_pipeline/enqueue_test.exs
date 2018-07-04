defmodule Tai.Trading.OrderPipeline.EnqueueTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  setup do
    on_exit(fn ->
      Tai.Trading.OrderStore.clear()
    end)

    test_pid = self()

    callback = fn previous_order, updated_order ->
      send(test_pid, {:callback_fired, previous_order, updated_order})
    end

    {:ok, callback: callback}
  end

  test "buy_limit enqueues an order and logs a message", %{callback: callback} do
    assert Tai.Trading.OrderStore.count() == 0

    log_msg =
      capture_log(fn ->
        order =
          Tai.Trading.OrderPipeline.buy_limit(
            :test_account_a,
            :btc_usdt,
            100.1,
            0.1,
            :fok,
            callback
          )

        assert Tai.Trading.OrderStore.count() == 1
        assert order.status == Tai.Trading.OrderStatus.enqueued()
        assert order.price == Decimal.new(100.1)
        assert order.size == Decimal.new(0.1)
        assert order.time_in_force == Tai.Trading.TimeInForce.fill_or_kill()
        assert_receive {:callback_fired, nil, %Tai.Trading.Order{status: :enqueued}}

        :timer.sleep(100)
      end)

    [order] = Tai.Trading.OrderStore.all()
    assert log_msg =~ ~r/\[order|client_id: #{order.client_id},status:enqueued\]/
  end

  test "sell_limit enqueues an order and logs a message", %{callback: callback} do
    assert Tai.Trading.OrderStore.count() == 0

    log_msg =
      capture_log(fn ->
        order =
          Tai.Trading.OrderPipeline.sell_limit(
            :test_account_a,
            :btc_usdt,
            100_000.1,
            0.01,
            :fok,
            callback
          )

        assert Tai.Trading.OrderStore.count() == 1
        assert order.status == Tai.Trading.OrderStatus.enqueued()
        assert order.price == Decimal.new(100_000.1)
        assert order.size == Decimal.new(0.01)
        assert order.time_in_force == Tai.Trading.TimeInForce.fill_or_kill()
        assert_receive {:callback_fired, nil, %Tai.Trading.Order{status: :enqueued}}
        :timer.sleep(100)
      end)

    [order] = Tai.Trading.OrderStore.all()
    assert log_msg =~ ~r/\[order|client_id: #{order.client_id},status:enqueued\]/
  end
end
