defmodule TLRSS.FeedReader do
  use GenServer

  alias TLRSS.FeedReader.RSS

  def start_link(init_feed, opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, init_feed, opts)
  end

  def get_entries(pid \\ __MODULE__) do
    GenServer.call(pid, :get_entries, 30000)
  end

  def get_feed(pid \\ __MODULE__), do: GenServer.call pid, :get_feed

  def init(init_feed), do: {:ok, init_feed}

  def handle_call(:get_entries, _from, feed) do
    items = RSS.get_entries(feed) |> Enum.map(&RSS.entry_to_item/1)

    {:reply, {:entries, items}, feed}
  end

  def handle_call(:get_feed, _from, feed) do
    {:reply, {:feed, feed}, feed}
  end
end
