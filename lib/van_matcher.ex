defmodule VanMatcher do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(VanMatcher.Endpoint, []),
      Honeydew.queue_spec(:queue),
      Honeydew.worker_spec(:queue, VanMatcher.Worker, num: 2)
    ]

    opts = [strategy: :one_for_one, name: VanMatcher.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    VanMatcher.Endpoint.config_change(changed, removed)
    :ok
  end
end
