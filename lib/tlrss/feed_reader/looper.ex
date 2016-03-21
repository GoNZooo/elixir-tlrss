defmodule TLRSS.FeedReader.Looper do
  @moduledoc"""
  Drives the flow of the application. This was separated out of a chain of
  forwarded results throughout the modules in order to keep them usable for
  other uses. It's much like the Driver module that was originally a part of
  the suite, but is instead a task that will run periodically.
  """
  #######
  # API #
  #######

  def start_link(manager \\ TLRSS.FeedReader.Manager,
                 sleep_time \\ 300_000) do
    Task.start_link(__MODULE__, :read_loop, [manager, sleep_time])
  end

  ############
  # Internal #
  ############

  def read_loop(manager, sleep_time) do
    TLRSS.FeedReader.Manager.feeds(manager)
    |> Enum.map(&(TLRSS.FeedReader.start_reader(&1)))
    |> Enum.flat_map(&(Task.await(&1)))
    |> TLRSS.ItemBucket.add()
    |> TLRSS.ItemFilter.filter()
    |> Enum.each(&(TLRSS.Download.download(&1)))

    :timer.sleep(sleep_time)
    read_loop(manager, sleep_time)
  end
end
