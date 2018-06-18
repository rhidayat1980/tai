defmodule Tai.Advisors.OrderBookCallbacksTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Tai.Advisor
  alias Tai.Markets.{OrderBook, PriceLevel, Quote}

  defmodule MyAdvisor do
    use Advisor

    def handle_order_book_changes(feed_id, symbol, changes, state) do
      send(:test, {feed_id, symbol, changes, state})
    end

    def handle_inside_quote(feed_id, symbol, inside_quote, changes, state) do
      send(:test, {feed_id, symbol, inside_quote, changes, state})

      state.store[:return_val] || :ok
    end
  end

  setup do
    Process.register(self(), :test)
    book_pid = start_supervised!({OrderBook, feed_id: :my_order_book_feed, symbol: :btc_usd})
    start_supervised!({Tai.ExchangeAdapters.Test.Account, :my_test_account})

    on_exit(fn ->
      Tai.Trading.OrderStore.clear()
    end)

    {:ok, %{book_pid: book_pid}}
  end

  test("handle_order_book_changes is called when it receives a broadcast message", %{
    book_pid: book_pid
  }) do
    start_supervised!({
      MyAdvisor,
      [
        advisor_id: :my_advisor,
        order_books: %{my_order_book_feed: [:btc_usd]},
        accounts: [:my_test_account],
        store: %{}
      ]
    })

    changes = %OrderBook{bids: %{101.2 => {1.1, nil, nil}}, asks: %{}}
    book_pid |> OrderBook.update(changes)

    assert_receive {
      :my_order_book_feed,
      :btc_usd,
      ^changes,
      %Advisor{}
    }
  end

  test("handle_inside_quote is called after the snapshot broadcast message", %{book_pid: book_pid}) do
    start_supervised!({
      MyAdvisor,
      [
        advisor_id: :my_advisor,
        order_books: %{my_order_book_feed: [:btc_usd]},
        accounts: [:my_test_account],
        store: %{}
      ]
    })

    snapshot = %OrderBook{
      bids: %{101.2 => {1.0, nil, nil}},
      asks: %{101.3 => {0.1, nil, nil}}
    }

    book_pid |> OrderBook.replace(snapshot)

    assert_receive {
      :my_order_book_feed,
      :btc_usd,
      %Quote{
        bid: %PriceLevel{price: 101.2, size: 1.0, processed_at: nil, server_changed_at: nil},
        ask: %PriceLevel{price: 101.3, size: 0.1, processed_at: nil, server_changed_at: nil}
      },
      ^snapshot,
      %Advisor{}
    }
  end

  test("handle_inside_quote logs a warning message when it returns an unknown type", %{
    book_pid: book_pid
  }) do
    start_supervised!({
      MyAdvisor,
      [
        advisor_id: :my_advisor,
        order_books: %{my_order_book_feed: [:btc_usd]},
        accounts: [:my_test_account],
        store: %{return_val: {:unknown, :return_val}}
      ]
    })

    snapshot = %OrderBook{
      bids: %{101.2 => {1.0, nil, nil}},
      asks: %{101.3 => {0.1, nil, nil}}
    }

    log_msg =
      capture_log(fn ->
        book_pid |> OrderBook.replace(snapshot)

        :timer.sleep(100)
      end)

    assert log_msg =~
             "[warn]  handle_inside_quote returned an invalid value: '{:unknown, :return_val}'"
  end

  test(
    "handle_inside_quote is called on broadcast changes when the inside bid price is >= to the previous bid or != size ",
    %{book_pid: book_pid}
  ) do
    start_supervised!({
      MyAdvisor,
      [
        advisor_id: :my_advisor,
        order_books: %{my_order_book_feed: [:btc_usd]},
        accounts: [:my_test_account],
        store: %{}
      ]
    })

    snapshot = %OrderBook{
      bids: %{101.2 => {1.0, nil, nil}},
      asks: %{101.3 => {0.1, nil, nil}}
    }

    book_pid |> OrderBook.replace(snapshot)

    assert_receive {
      :my_order_book_feed,
      :btc_usd,
      %Quote{
        bid: %PriceLevel{price: 101.2, size: 1.0, processed_at: nil, server_changed_at: nil},
        ask: %PriceLevel{price: 101.3, size: 0.1, processed_at: nil, server_changed_at: nil}
      },
      ^snapshot,
      %Advisor{}
    }

    changes = %OrderBook{bids: %{101.2 => {1.1, nil, nil}}, asks: %{}}

    refute_receive {
      _feed_id,
      _symbol,
      _bid,
      _ask,
      _changes,
      %Advisor{}
    }

    book_pid |> OrderBook.update(changes)

    assert_receive {
      :my_order_book_feed,
      :btc_usd,
      %Quote{
        bid: %PriceLevel{price: 101.2, size: 1.1, processed_at: nil, server_changed_at: nil},
        ask: %PriceLevel{price: 101.3, size: 0.1, processed_at: nil, server_changed_at: nil}
      },
      ^changes,
      %Advisor{}
    }
  end

  test(
    "handle_inside_quote is called on broadcast changes when the inside ask price is <= to the previous ask or != size ",
    %{book_pid: book_pid}
  ) do
    start_supervised!({
      MyAdvisor,
      [
        advisor_id: :my_advisor,
        order_books: %{my_order_book_feed: [:btc_usd]},
        accounts: [:my_test_account],
        store: %{}
      ]
    })

    snapshot = %OrderBook{
      bids: %{101.2 => {1.0, nil, nil}},
      asks: %{101.3 => {0.1, nil, nil}}
    }

    book_pid |> OrderBook.replace(snapshot)

    assert_receive {
      :my_order_book_feed,
      :btc_usd,
      %Quote{
        bid: %PriceLevel{price: 101.2, size: 1.0, processed_at: nil, server_changed_at: nil},
        ask: %PriceLevel{price: 101.3, size: 0.1, processed_at: nil, server_changed_at: nil}
      },
      ^snapshot,
      %Advisor{}
    }

    changes = %OrderBook{bids: %{}, asks: %{101.3 => {0.2, nil, nil}}}

    refute_receive {
      _feed_id,
      _symbol,
      _bid,
      _ask,
      _changes,
      %Advisor{}
    }

    book_pid |> OrderBook.update(changes)

    assert_receive {
      :my_order_book_feed,
      :btc_usd,
      %Quote{
        bid: %PriceLevel{price: 101.2, size: 1.0, processed_at: nil, server_changed_at: nil},
        ask: %PriceLevel{price: 101.3, size: 0.2, processed_at: nil, server_changed_at: nil}
      },
      ^changes,
      %Advisor{}
    }
  end

  test "handle_inside_quote can store data in the state", %{book_pid: book_pid} do
    start_supervised!({
      MyAdvisor,
      [
        advisor_id: :my_advisor,
        order_books: %{my_order_book_feed: [:btc_usd]},
        accounts: [:my_test_account],
        store: %{return_val: {:ok, %{store: %{hello: "world"}}}}
      ]
    })

    snapshot = %OrderBook{
      bids: %{101.2 => {1.0, nil, nil}},
      asks: %{101.3 => {0.1, nil, nil}}
    }

    book_pid |> OrderBook.replace(snapshot)

    assert_receive {
      :my_order_book_feed,
      :btc_usd,
      %Quote{
        bid: %PriceLevel{price: 101.2, size: 1.0, processed_at: nil, server_changed_at: nil},
        ask: %PriceLevel{price: 101.3, size: 0.1, processed_at: nil, server_changed_at: nil}
      },
      ^snapshot,
      %Advisor{}
    }

    changes = %OrderBook{bids: %{}, asks: %{101.3 => {0.2, nil, nil}}}
    book_pid |> OrderBook.update(changes)

    assert_receive {
      :my_order_book_feed,
      :btc_usd,
      %Quote{
        bid: %PriceLevel{price: 101.2, size: 1.0, processed_at: nil, server_changed_at: nil},
        ask: %PriceLevel{price: 101.3, size: 0.2, processed_at: nil, server_changed_at: nil}
      },
      ^changes,
      %Advisor{advisor_id: :my_advisor, store: %{hello: "world"}}
    }
  end
end
