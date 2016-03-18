defmodule TLRSS.FeedReader.Looper do
  alias TLRSS.FeedReader.Supervisor, as: ReaderSup
  #######
  # API #
  #######

  def start_link(manager \\ TLRSS.FeedReader.Manager,
                 sleep_time \\ 300_000,
                 opts \\ [name: __MODULE__]) do
    Task.start_link(__MODULE__, :read_loop, [manager, sleep_time])
  end

  ############
  # Internal #
  ############

  def read_loop(manager, sleep_time) do
    feeds = TLRSS.FeedReader.Manager.get_feeds(manager)

    entries = feeds |> Enum.each(&(ReaderSup.start_child(&1)))
    new_items = TLRSS.ItemBucket.add_items(entries)
    matches = TLRSS.ItemFilter.filter(new_items)

    matches |> Enum.each(&(TLRSS.Download.download(&1)))

    :timer.sleep(sleep_time)
    read_loop(manager, sleep_time)
  end
end
