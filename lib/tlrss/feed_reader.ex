defmodule TLRSS.FeedReader do
  @moduledoc"""
  Module that handles reading of feeds. A FeedReader is
  a simple Task that will read and re-read a given RSS feed
  in given intervals.

  When items are received, the FeedReader sends them to the
  ItemBucket module where they are stored, effectively keeping
  the state away from the same process that reads the feed.
  """
  alias TLRSS.FeedReader.RSS
  alias TLRSS.FeedReader.FeedSpec
  alias TLRSS.ItemBucket

  require Logger

  @spec start_link(FeedSpec.t) :: {:ok, pid}
  @doc"""
  Takes a FeedSpec.t for which feed should be read by the FeedReader.

  The reading is done via a Task that will start read_rss/2 which will
  then recurse in a given time interval to loop.
  """
  def start_link(init_feed) do
    Task.start_link(__MODULE__, :read_rss, [init_feed])
  end

  @spec read_rss(FeedSpec.t, number) :: :ok
  @doc"""
  Reads a feed, responding to the return value of the RSS module.
  If return value is good, will take the returned entries and pass them to
  the ItemBucket module. Upon error, will log error to stdout.
  """
  def read_rss(init_feed, sleep_time \\ 300000) do
    case RSS.get_entries(init_feed) do
      {:entries, entries} ->
        items = Enum.map(entries, &RSS.entry_to_item/1)
        ItemBucket.add_items(items)
      {:error, reason} ->
        Logger.error(reason)
    end

    :timer.sleep(sleep_time)
    read_rss(init_feed)
  end
end
