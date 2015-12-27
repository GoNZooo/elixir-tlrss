defmodule TLRSS.ItemBucket do
  use GenServer

  def start_link(init_items \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, init_items, opts)
  end

  def get_items(pid) do
    GenServer.call(pid, :get_items)
  end

  def add_items(pid, items) do
    GenServer.call(pid, {:add_items, items})
  end

  def remove_items(pid, items) do
    GenServer.cast(pid, {:remove_items, items})
  end

  def remove_matching(pid, predicate) do
    GenServer.cast(pid, {:remove_matching, predicate})
  end

  defp item_seen?(items, item) do
    Enum.member? items, item
  end

  def init(init_items) do
    {:ok, init_items}
  end

  def handle_call(:get_items, _from, items) do
    {:reply, {:items, items}, items}
  end

  def handle_call({:add_items, new_items}, _from, items) do
    {seen_items, new_items}= new_items
    |> Enum.partition fn i -> item_seen? items, i end

    {:reply, {:ok, new_items}, new_items ++ items}
  end

  def handle_cast({:remove_items, items_to_delete}, items) do
    {:noreply, Enum.filter(items, fn i -> not i in items_to_delete end)}
  end

  def handle_cast({:remove_matching, predicate}, items) do
    {:noreply, Enum.reject(items, predicate)}
  end
end
