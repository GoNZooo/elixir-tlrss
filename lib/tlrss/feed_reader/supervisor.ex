defmodule TLRSS.FeedReader.Supervisor do
  @moduledoc"""
  Module to keep track of and supervise the FeedReaders. This is interacted with
  by the FeedReader.Manager and only through that. As such, it's not advisable
  to add children without going through the manager.
  """
  use Supervisor

  alias TLRSS.FeedReader.FeedSpec

  #######
  # API #
  #######

  @spec start_link([name: atom]) :: Supervisor.on_start()
  def start_link(opts \\ [name: __MODULE__]) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  @spec start_child(FeedSpec.t) :: Supervisor.Spec.on_start
  def start_child(feed_url) do
    Supervisor.start_child(__MODULE__, [feed_url])
  end

  ############
  # Internal #
  ############

  def init([]) do
    children = [
      worker(TLRSS.FeedReader, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
