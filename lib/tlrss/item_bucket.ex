defmodule TLRSS.ItemBucket do
  use GenServer

  alias TLRSS.Item

  #######
  # API #
  #######

  def start_link(init_items \\ [], opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, init_items, opts)
  end

  def get_items(pid \\ __MODULE__) do
    GenServer.call(pid, :get_items)
  end

  def add_items(items_to_add, pid \\ __MODULE__) do
    GenServer.cast(pid, {:add_items, items_to_add})
  end

  def remove_items(items_to_remove, pid \\ __MODULE__) do
    GenServer.cast(pid, {:remove_items, items_to_remove})
  end

  ############
  # Internal #
  ############

  defp _new_items(current_items, items_to_add) do
    Enum.reject(items_to_add, &(Map.has_key? current_items, &1.name))
  end

  defp _add_items(current_items, items_to_add) do
    Enum.into(items_to_add, current_items, fn i = %Item{} -> {i.name, i} end)
  end

  defp _remove_items(current_items, items_to_remove) do
    Map.drop current_items, Enum.map(items_to_remove, &(&1.name))
  end

  def init(init_items) do
    {:ok, Enum.into(init_items, %{}, fn i = %Item{} -> {i.name, i} end)}
  end

  def handle_call(:get_items, _from, current_items) do
    {:reply, {:items, current_items}, current_items}
  end

  def handle_cast({:add_items, items_to_add}, current_items) do
    new_items = _new_items current_items, items_to_add
    TLRSS.ItemFilter.filter(new_items)
    {:noreply, _add_items(current_items, new_items)}
  end

  def handle_cast({:remove_items, items_to_remove}, current_items) do
    {:noreply, _remove_items(current_items, items_to_remove)}
  end
end
