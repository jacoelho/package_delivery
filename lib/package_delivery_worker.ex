defmodule PackageDelivery.Worker do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], [])
  end


  def handle_call({:deploy, options}, _from, state) do
    System.cmd(options)
    Agent.update(:collector, &([options|&1]))
    {:reply, "results #{options}", state}
  end

end
