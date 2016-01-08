defmodule TLRSS.FeedReader.Manager do
  use GenServer
  alias TLRSS.FeedReader.FeedSpec

  #######
  # API #
  #######

  @spec start_link([FeedSpec.t], pid, [name: atom]) :: {:ok, GenServer.on_start}
  def start_link(feeds \\ Application.get_env(:tlrss, :rss_feeds),
                 reader_supervisor \\ TLRSS.FeedReader.Supervisor,
                 opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, {feeds, reader_supervisor}, opts)
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

  def init({feeds, reader_sup}) do
    Enum.each(feeds, &(TLRSS.FeedReader.Supervisor.start_child(&1)))
    {:ok, {feeds, reader_sup}}
  end

  def handle_cast({:add_feed, feed}, {feeds, reader_sup}) do
    TLRSS.FeedReader.Supervisor.start_child(feed)
    {:noreply, {[feed | feeds], reader_sup}}
  end

  def handle_call(:get_feeds, _from, {feeds, reader_sup}) do
    {:reply, {:feeds, feeds}, {feeds, reader_sup}}
  end
end
