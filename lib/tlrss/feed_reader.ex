defmodule TLRSS.FeedReader do
  use GenServer

  alias TLRSS.RSS

  def start_link(init_feeds \\ [Application.get_env(:tlrss, :rss_url)], opts \\ []) do
    GenServer.start_link(__MODULE__, init_feeds, opts)
  end

  def get_entries(pid), do: GenServer.call pid, :get_entries

  def init(init_feeds), do: {:ok, init_feeds}

  def handle_call(:get_entries, _from, feeds) do
    entry_items = feeds
    |> Enum.flat_map(&RSS.get_entries/1)
    |> Enum.map(&RSS.entry_to_item/1)

    {:reply, {:entries, entry_items}, feeds}
  end
end
