defmodule TLRSS.FeedReader do
  @moduledoc"""
  Module that handles reading of feeds. A FeedReader is
  a simple Task that will read a given RSS feed.
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
  """
  def read_rss(init_feed) do
    case RSS.get_entries(init_feed) do
      {:entries, entries} ->
        Enum.map(entries, &RSS.entry_to_item/1)
      {:error, reason} ->
        Logger.error(reason)
    end
  end
end
