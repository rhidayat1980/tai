ExUnit.start()
ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]

Ecto.Adapters.SQL.Sandbox.mode(Tai.Repo, :manual)
