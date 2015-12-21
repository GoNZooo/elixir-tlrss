defmodule TLRSS.ItemBucket do
  use GenServer

  def start_link(init_items \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, init_items, opts)
  end

  def get_items(pid) do
    GenServer.call(pid, :get_items)
  end

  def add_item(pid, item) do
    GenServer.call(pid, {:add_item, item})
  end

  def add_items(pid, items) do
    GenServer.call(pid, {:add_items, items})
  end

  def remove_item(pid, item) do
    GenServer.cast(pid, {:remove_item, item})
  end

  def seen_item?(pid, item) do
    GenServer.call(pid, {:seen_item?, item})
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

  def handle_call({:add_item, item}, _from, items) do
    if item_seen? items, item do
      {:reply, {:seen, item}, items}
    else
      {:reply, {:ok, item}, [item|items]}
    end
  end

  def handle_call({:add_items, new_items}, _from, items) do
    {seen_items, new_items}= new_items
    |> Enum.partition fn i -> item_seen? items, i end

    {:reply, {{:ok, new_items}, {:seen, seen_items}}, new_items ++ items}
  end

  def handle_call({:seen_item?, item}, _from, items) do
    if item_seen? items, item do
      {:reply, {:seen, item}, items}
    else
      {:reply, {:not_seen, item}, items}
    end
  end

  def handle_cast({:remove_item, item}, items) do
    {:noreply, List.delete(items, item)}
  end
end
