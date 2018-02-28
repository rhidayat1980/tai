use Mix.Config

config :echo_boy,     port:             4200

config :ex_gdax,      api_key:         System.get_env("GDAX_API_KEY"),
                      api_secret:      System.get_env("GDAX_API_SECRET"),
                      api_passphrase:  System.get_env("GDAX_API_PASSPHRASE")

config :ex_bitstamp,  api_key:         System.get_env("BITSTAMP_API_KEY"),
                      api_secret:      System.get_env("BITSTAMP_API_SECRET"),
                      customer_id:     System.get_env("BITSTAMP_CUSTOMER_ID")

config :tai,          order_book_feeds: %{
                        gdax: [
                          adapter: Tai.ExchangeAdapters.Gdax.OrderBookFeed,
                          order_books: [:btcusd, :ltcusd, :ethusd]
                        ],
                        binance: [
                          adapter: Tai.ExchangeAdapters.Binance.OrderBookFeed,
                          order_books: [:btcusdt]
                        ]
                      }

config :tai,          order_feeds: %{
                        gdax_main: [
                          adapter: Tai.ExchangeAdapters.Gdax.OrderFeed,
                          symbols: [:btcusd, :ltcusd, :ethusd],
                          opts: %{
                            api_key:          System.get_env("GDAX_API_KEY"),
                            api_secret:       System.get_env("GDAX_API_SECRET"),
                            api_passphrase:   System.get_env("GDAX_API_PASSPHRASE")
                          }
                        ]
                      }

config :tai,          exchanges: %{
                        gdax: [
                          supervisor: Tai.ExchangeAdapters.Gdax.Supervisor,
                          # order_books: [:btcusd, :ltcusd, :ethusd],
                          # opts: %{
                          #   api_key:          System.get_env("GDAX_API_KEY"),
                          #   api_secret:       System.get_env("GDAX_API_SECRET"),
                          #   api_passphrase:   System.get_env("GDAX_API_PASSPHRASE")
                          # }
                        ],
                        bitstamp: [
                          supervisor: Tai.ExchangeAdapters.Bitstamp.Supervisor
                        ]
                      }

config :tai,          advisors: %{
                        spread_capture: Support.Advisors.SpreadCapture
                      }
