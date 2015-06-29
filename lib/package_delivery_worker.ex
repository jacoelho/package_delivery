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
    instructions = [
      { "git", ~w(clone --depth 1 https://github.com/jacoelho/ansible-deploy.git /tmp/deploy) },
      { "ansible-playbook", ~w(-i /tmp/deploy/inventory /tmp/deploy/playbook.yml -e env=#{options.environment} -e service=#{options.service}) },
    ]

    deploy = Enum.reduce(instructions, :ok, fn({cmd, args}, state) ->
      if state == :ok do
        {_output, status} = System.cmd(cmd, args)

        case status do
         0 -> :ok
         _ -> :failure
        end
      else
        :failure
      end
    end)

    System.cmd("rm", ["-fr", "/tmp/deploy"])

    case deploy do
      :ok      -> System.cmd("curl", ~w(#{options.callback_success}))
      :failure -> System.cmd("curl", ~w(#{options.callback_failure}))
    end

    {:noreply , state}
  end


end
