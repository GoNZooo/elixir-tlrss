defmodule TLRSS.FeedReader.Looper.Supervisor do
  use Supervisor

  #######
  # API #
  #######

  @spec start_link([name: atom]) :: Supervisor.on_start()
  def start_link(opts \\ [name: __MODULE__]) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  ############
  # Internal #
  ############

  def init([]) do
    children = [
      worker(TLRSS.FeedReader.Looper, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
