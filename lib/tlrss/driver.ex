defmodule TLRSS.Driver do
  require Logger

  alias TLRSS.FeedReader
  alias TLRSS.ItemBucket
  alias TLRSS.ItemFilter
  alias TLRSS.Download

  def start_link(sleep_time \\ 300000) do
    Logger.info("Driver started.")
    Task.start_link(__MODULE__, :drive, [sleep_time])
  end

  def drive(sleep_time) do
    Logger.debug("Driving...")
    {:entries, entries} = FeedReader.get_entries
    {:new_items, new_items} = ItemBucket.add_items entries
    {:matches, matches} = ItemFilter.matches? new_items

    Enum.each(matches, &(Download.download(&1.link)))
    Enum.each(matches, &(Logger.info("#{&1.name} downloaded")))

    :timer.sleep(sleep_time)
    drive(sleep_time)
  end
end
