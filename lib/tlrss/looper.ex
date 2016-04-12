defmodule TLRSS.Looper do
  require Logger
  def start_looper(feed, sleep_time \\ 300_000) do
    Task.Supervisor.start_child(TLRSS.TaskSupervisor,
                                __MODULE__,
                                :read_loop,
                                [feed, sleep_time])
  end

  def read_loop(feed, sleep_time) do
    Logger.debug("Reading #{feed}")
    case TLRSS.RSS.read_rss(feed) do
      items when is_list(items) ->
        items
        |> TLRSS.ItemBucket.add()
        |> TLRSS.ItemFilter.filter()
        |> Enum.each(&TLRSS.Download.download(&1))

      _ -> :ok
    end

    :timer.sleep(sleep_time)
    read_loop(feed, sleep_time)
  end
end
