defmodule PackageDelivery.Worker do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(_) do
    {:ok, nil}
  end

  def deploy(pid, options) do
    :gen_server.cast(pid, {:deploy, options})
  end

  def handle_cast({:deploy, options}, state) do
    System.cmd(options)
    Agent.update(:collector, &([options|&1]))
    {:noreply , state}
  end

end
