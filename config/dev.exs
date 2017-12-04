use Mix.Config

config :tai,      Tai.Repo,
                  adapter: Ecto.Adapters.Postgres,
                  database: "tai_dev",
                  hostname: "localhost",
                  port: "5432"

config :ex_gdax,  api_key:        System.get_env("GDAX_API_KEY"),
                  api_secret:     System.get_env("GDAX_API_SECRET"),
                  api_passphrase: System.get_env("GDAX_API_PASSPHRASE")

config :tai,      exchanges: %{
                    gdax: Tai.Exchanges.Adapters.Gdax
                  }

config :tai,      strategies: %{
                    info: Tai.Strategies.Info
                  }
