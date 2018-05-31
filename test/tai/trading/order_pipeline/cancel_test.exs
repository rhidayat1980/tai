defmodule Tai.Trading.OrderPipeline.CancelTest do
  use ExUnit.Case

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

  test "cancel changes the given pending orders to cancelling and sends the request to the exchange in the background",
       %{callback: callback} do
    order =
      Tai.Trading.OrderPipeline.buy_limit(
        :test_account_a,
        :btcusd_pending,
        100.1,
        0.1,
        :gtc,
        callback
      )

    assert_receive {
      :callback_fired,
      %Tai.Trading.Order{status: :enqueued},
      %Tai.Trading.Order{status: :pending}
    }

    log_msg =
      capture_log(fn ->
        assert {:ok, %Tai.Trading.Order{status: :cancelling}} =
                 Tai.Trading.OrderPipeline.cancel(order)

        assert_receive {
          :callback_fired,
          %Tai.Trading.Order{status: :pending},
          %Tai.Trading.Order{status: :cancelling}
        }

        assert_receive {
          :callback_fired,
          %Tai.Trading.Order{status: :cancelling},
          %Tai.Trading.Order{status: :cancelled}
        }
      end)

    assert log_msg =~ "order cancelling - client_id:"
    assert log_msg =~ "order cancelled - client_id:"
  end
end
