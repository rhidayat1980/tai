use Mix.Config

config :tai, accounts: %{
  test_account_a: [
    Tai.Accounts.Adapters.TestSupervisor,
    Tai.Accounts.Adapters.Test,
    []
  ],
  test_account_b: [
    Tai.Accounts.Adapters.TestSupervisor,
    Tai.Accounts.Adapters.Test,
    [config_key: "some_key"]
  ]
}
