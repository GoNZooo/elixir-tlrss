defmodule TLRSS.FeedReader.Manager do
  @moduledoc"""
  Module that handles initial and subsequent adding of
  all new FeedReader processes to the FeedReader supervisor.
  """
  use GenServer
  alias TLRSS.FeedReader.FeedSpec
  alias TLRSS.FeedReader.Supervisor, as: ReaderSup

  #######
  # API #
  #######

  @spec start_link([FeedSpec.t], [name: atom]) :: GenServer.on_start
  def start_link(feeds \\ Application.get_env(:tlrss, :feeds),
                 opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, feeds, opts)
  end

  @spec add_feed(FeedSpec.t, pid) :: :ok
  @doc"""
  Used to add a feed to the manager (and to the supervisor) at runtime.
  """
  def add_feed(feed, pid \\ __MODULE__) do
    GenServer.cast(pid, {:add_feed, feed})
  end

  @spec get_feeds(pid) :: [FeedSpec.t]
  @doc"""
  Fetches and returns a list of the feeds registered with the manager.
  These are not guaranteed to be the only feeds registered in the supervisor,
  as one could be added manually to the supervisor.

  However, if one does all the feed managing through the manager, this
  should not happen.
  """
  def get_feeds(pid \\ __MODULE__) do
    GenServer.call(pid, :get_feeds)
  end

  ############
  # Internal #
  ############

  def init(feeds) do
    {:ok, feeds}
  end

  def handle_cast({:add_feed, feed}, feeds) do
    ReaderSup.start_child(feed)
    {:noreply, [feed | feeds]}
  end

  def handle_call(:get_feeds, _from, feeds) do
    {:reply, feeds, feeds}
  end
end
