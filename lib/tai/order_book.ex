defmodule Tai.OrderBook do
  @moduledoc """
  Documentation for Tai.OrderBook.
  """

  use GenServer

  def start_link do
    GenServer.start_link(
      __MODULE__,
      %{
        bid: %{},
        ask: %{},
        last_timestamp: DateTime.utc_now()
      }
    )
  end

  def get(pid, depth) when depth > 0 do
    GenServer.call(pid, {:get, depth})
  end

  def put(pid, side, price, amount, timestamp) do
    GenServer.cast(pid, {:put, side, price, amount, timestamp})
  end

  def handle_call({:get, depth}, _from, book) when depth > 0 do
    bid = Enum.sort(book.bid)
          |> Enum.reverse
          |> Enum.take(depth)
    ask = Enum.sort(book.ask)
          |> Enum.take(depth)

    {:reply, %{bid: bid, ask: ask}, book}
  end

  def handle_cast(
    {:put, side, price, remaining, timestamp},
    book
  ) when side in [:bid, :ask] and remaining == 0 do
    new_book_side = book[side]
               |> Map.delete(price)
    new_book = book
               |> with_new_side(side, new_book_side, timestamp)

    {:noreply, new_book}
  end

  def handle_cast(
    {:put, side, price, remaining, timestamp},
    book
  ) when side in [:bid, :ask] do
    new_book_side = book[side]
               |> Map.put(price, {remaining, timestamp})
    new_book = book
               |> with_new_side(side, new_book_side, timestamp)

    {:noreply, new_book}
  end

  defp with_new_side(book, side, new_book_side, timestamp) do
    book
    |> Map.put(side, new_book_side)
    |> Map.put(:last_timestamp, timestamp)
  end
end
