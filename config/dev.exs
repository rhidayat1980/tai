use Mix.Config

config :tai, accounts: %{
  bitmex: [
    Tai.Accounts.Adapters.BitmexSupervisor,
    Tai.Accounts.Adapters.Bitmex,
    [
      api_key: System.get_env("BITMEX_API_KEY"),
      secret: System.get_env("BITMEX_SECRET")
    ]
  ]
}
