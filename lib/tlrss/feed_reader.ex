defmodule TLRSS.FeedReader do
  alias TLRSS.FeedReader.RSS

  def start_link(init_feed, opts) do
    Task.start_link(__MODULE__, :read_rss, [init_feed])
  end

  def read_rss(init_feed, sleep_time \\ 300000) do
    items = RSS.get_entries(init_feed) |> Enum.map(&RSS.entry_to_item/1)
    TLRSS.ItemBucket.add_items(items)

    :timer.sleep(sleep_time)
    read_rss(init_feed)
  end
end
