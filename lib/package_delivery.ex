defmodule PackageDelivery do
  use Application

  def deploy(options) do
    :poolboy.transaction(:deploy_pool, fn(pid) ->
      PackageDelivery.Worker.deploy(pid, options) end)
  end

  def get_result do
    Agent.get(:collector, &(&1))
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    pool_options = [
      name: {:local, :deploy_pool},
      worker_module: PackageDelivery.Worker,
      size: 5,
      max_overflow: 0
    ]

    children = [
      :poolboy.child_spec(:deploy_pool, pool_options, []),
      worker(Agent, [fn -> [] end, [name: :collector]])
    ]

    opts = [strategy: :one_for_one, name: PackageDelivery.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
