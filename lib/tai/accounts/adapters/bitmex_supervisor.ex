defmodule Tai.Accounts.Adapters.BitmexSupervisor do
  use Supervisor

  def start_link(_state) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_state) do
    # Supervisor.init
  end
end
