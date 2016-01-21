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

  require Logger

  @spec start_link(String.t) :: {:ok, pid}
  def start_link(init_feed) do
    Task.start_link(__MODULE__, :read_rss, [init_feed])
  end

  @spec read_rss(String.t, number) :: :ok
  def read_rss(init_feed, sleep_time \\ 300000) do
    case RSS.get_entries(init_feed) do
      {:entries, entries} ->
        items = Enum.map(entries, &RSS.entry_to_item/1)
        TLRSS.ItemBucket.add_items(items)
      {:error, reason} ->
        Logger.error(reason)
    end

    :timer.sleep(sleep_time)
    read_rss(init_feed)
  end
end
