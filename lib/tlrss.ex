defmodule TLRSS do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the Ecto repository
      supervisor(Task.Supervisor, [[name: TLRSS.TaskSupervisor]]),
      worker(TLRSS.Download, []),
      worker(TLRSS.ItemFilter, []),
      worker(TLRSS.ItemBucket, []),
      worker(TLRSS.Manager, []),
      # Here you could define other workers and supervisors as children
      # worker(Wedding.Worker, [arg1, arg2, arg3]),
    ]

    opts = [strategy: :one_for_one, name: TLRSS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
