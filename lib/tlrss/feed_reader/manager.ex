defmodule TLRSS.FeedReader.Manager do
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
  def add_feed(feed, pid \\ __MODULE__) do
    GenServer.cast(pid, {:add_feed, feed})
  end

  @spec get_feeds(pid) :: [FeedSpec.t]
  def get_feeds(pid \\ __MODULE__) do
    GenServer.call(pid, :get_feeds)
  end

  ############
  # Internal #
  ############

  def init(feeds) do
    feeds
    |> Enum.each(&(ReaderSup.start_child(&1)))
    {:ok, feeds}
  end

  def handle_cast({:add_feed, feed}, feeds) do
    ReaderSup.start_child(feed)
    {:noreply, [feed | feeds]}
  end

  def handle_call(:get_feeds, _from, feeds) do
    {:reply, {:feeds, feeds}, feeds}
  end
end
