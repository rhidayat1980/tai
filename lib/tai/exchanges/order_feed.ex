defmodule Tai.Exchanges.OrderFeed do
  @moduledoc """
  Behaviour to connect to a WebSocket that streams status updates for orders
  """

  @doc """
  Invoked after the process is started and should be used to setup subscriptions
  """
  @callback subscribe_to_orders(pid :: Pid.t, symbols :: List.t) :: :ok | :error

  @doc """
  Invoked after a message is received on the socket and should be used to process the message
  """
  @callback handle_msg(msg :: Map.t, feed_id :: Atom.t) :: nil

  @doc """
  Returns an atom that will identify the process

  ## Examples

    iex> Tai.Exchanges.OrderFeed.to_name(:my_test_feed)
    :order_feed_my_test_feed
  """
  def to_name(feed_id) do
    :"order_feed_#{feed_id}"
  end

  defmacro __using__(_) do
    quote location: :keep do
      use WebSockex

      require Logger

      alias Tai.Exchanges.Config

      @behaviour Tai.Exchanges.OrderFeed

      def url, do: raise "No url/0 in #{__MODULE__}"

      def start_link(feed_id) do
        url()
        |> WebSockex.start_link(
          __MODULE__,
          feed_id,
          name: feed_id |> Tai.Exchanges.OrderFeed.to_name
        )
        |> init_subscriptions(feed_id)
      end

      @doc false
      defp init_subscriptions({:ok, pid}, feed_id) do
        pid
        |> subscribe_to_orders(feed_id |> Config.order_feed_symbols)
        |> case do
          :ok -> {:ok, pid}
          :error -> {:error, "could not subscribe to orders"}
        end
      end
      @doc false
      defp init_subscriptions({:error, reason}) do
        {:error, reason}
      end

      @doc false
      def handle_frame({:text, msg}, feed_id) do
        Logger.debug "#{feed_id |> Tai.Exchanges.OrderFeed.to_name} msg: #{msg}"

        msg
        |> JSON.decode!
        |> parse_msg(feed_id)

        {:ok, feed_id}
      end
      @doc false
      def handle_frame({type, msg}, state) do
        Logger.debug "Unhandled frame #{__MODULE__} - type: #{inspect type}, msg: #{inspect msg}"

        {:ok, state}
      end

      @doc false
      defp parse_msg(msg, feed_id) do
        Logger.debug "#{feed_id |> Tai.Exchanges.OrderFeed.to_name} received msg: #{inspect msg}"

        msg
        |> handle_msg(feed_id)
      end

      @doc false
      def handle_disconnect(conn_status, feed_id) do
        Logger.error "#{feed_id |> Tai.Exchanges.OrderFeed.to_name} disconnected - reason: #{inspect conn_status.reason}"

        {:ok, feed_id}
      end

      defoverridable [url: 0]
    end
  end
end
