defmodule TLRSS.FeedReader.Looper do
  def read_loop(feed, sleep_time) do
    TLRSS.FeedReader.start_reader(feed)
    |> TLRSS.ItemBucket.add()
    |> TLRSS.ItemFilter.filter()
    |> Enum.each(&TLRSS.Download.download(&1))

    :timer.sleep(sleep_time)
    read_loop(manager, sleep_time)
  end
end
