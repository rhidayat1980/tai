defmodule Tai.ExchangeAdapters.Gdax.OrderFeed do
  use Tai.Exchanges.OrderFeed

  require Logger

  alias Tai.{ExchangeAdapters.Gdax.Product}

  def url, do: "wss://ws-feed.gdax.com/"

  def subscribe_to_orders(name, symbols) do
    [name: name, symbols: symbols, channels: ["user", "heartbeat"]]
    |> subscribe
  end

  def handle_msg(
    %{
      "order_id" => order_id,
      "order_type" => _order_type,
      "price" => price,
      "product_id" => _product_id,
      "profile_id" => _profile_id,
      "sequence" => sequence,
      "side" => _side,
      "size" => size,
      "time" => _time,
      "type" => _type,
      "user_id" => _user_id
    },
    _feed_id
  ) do
    Logger.info "--- handle_msg for GDAX order feed - order_id: #{inspect order_id} | price: #{inspect price} | size: #{inspect size} | sequence: #{inspect sequence}"
  end
  def handle_msg(
    %{
      "order_id" => order_id,
      "price" => price,
      "product_id" => _product_id,
      "profile_id" => _profile_id,
      "reason" => _reason,
      "remaining_size" => remaining_size,
      "sequence" => sequence,
      "side" => _side,
      "time" => _time,
      "type" => _type,
      "user_id" => _user_id
    },
    _feed_id
  ) do
    Logger.info "--- handle_msg for GDAX order feed - order_id: #{inspect order_id} | price: #{inspect price} | remaining_size: #{inspect remaining_size} | sequence: #{inspect sequence}"
  end
  def handle_msg(
    %{
      "type" => "heartbeat",
      "product_id" => _product_id,
      "last_trade_id" => _last_trade_id,
      "sequence" => _sequence,
      "time" => _time
    },
    _feed_id
  ) do
  end
  def handle_msg(
    %{
      "type" => "subscriptions",
      "channels" => _channels
    },
    _feed_id
  ) do
  end
  def handle_msg(unhandled_msg, feed_id) do
    Logger.warn "#{feed_id |> Tai.Exchanges.OrderFeed.to_name} unhandled message: #{inspect unhandled_msg}"
  end

  defp subscribe(name: name, symbols: symbols, channels: channels) do
    timestamp = :os.system_time(:seconds)
    method = "GET"
    path = "/users/self/verify"
    body = %{}
    config = %{
      api_key: Application.get_env(:ex_gdax, :api_key),
      api_passphrase: Application.get_env(:ex_gdax, :api_passphrase),
      api_secret: Application.get_env(:ex_gdax, :api_secret)
    }

    [
      name: name,
      msg: %{
        "type" => "subscribe",
        "product_ids" => Product.to_product_ids(symbols),
        "channels" => channels,
        "signature" => sign_request(timestamp, method, path, body, config),
        "key" => config.api_key,
        "passphrase" => config.api_passphrase,
        "timestamp" => timestamp
      }
    ]
    |> send_msg
  end
  defp sign_request(timestamp, method, path, body, config) do
    key = Base.decode64!(config.api_secret || "")
    body = if Enum.empty?(body), do: "", else: Poison.encode!(body)
    data = "#{timestamp}#{method}#{path}#{body}"

    :sha256
    |> :crypto.hmac(key, data)
    |> Base.encode64()
  end

  defp send_msg(name: name, msg: msg) do
    name
    |> WebSockex.send_frame({:text, JSON.encode!(msg)})
  end
end
