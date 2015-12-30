defmodule TLRSS.ItemBucket do
  use GenServer

  alias TLRSS.Item

  #######
  # API #
  #######
  def start_link(init_items \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, init_items, opts)
  end

  def get_items(pid) do
    GenServer.call pid, :get_items
  end

  def add_items(pid, items_to_add) do
    GenServer.call pid, {:add_items, items_to_add}
  end

  def remove_items(pid, items_to_remove) do
    GenServer.cast pid, {:remove_items, items_to_remove}
  end

  ############
  # Handling #
  ############

  defp _new_items(current_items, items_to_add) do
    Enum.reject items_to_add, &(Map.has_key? current_items, &1.name)
  end

  defp _add_items(current_items, items_to_add) do
    Enum.into items_to_add, current_items, fn i = %Item{} -> {i.name, i} end
  end

  defp _remove_items(current_items, items_to_remove) do
    Map.drop current_items, Enum.map(items_to_remove, &(&1.name))
  end

  def init(init_items) do
    {:ok, Enum.into(init_items, %{}, fn i = %Item{} -> {i.name, i} end)}
  end

  def handle_call(:get_items, _from, current_items) do
    {:reply, current_items, current_items}
  end

  def handle_call({:add_items, items_to_add}, _from, current_items) do
    new_items = _new_items current_items, items_to_add
    {:reply, {:new_items, new_items}, _add_items(current_items, new_items)}
  end

  def handle_cast({:remove_items, items_to_remove}, current_items) do
    {:noreply, _remove_items(current_items, items_to_remove)}
  end
end
