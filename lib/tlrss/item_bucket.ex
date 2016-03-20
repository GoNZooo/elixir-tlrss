defmodule TLRSS.ItemBucket do
  @moduledoc"""
  Module to hold the items fetched from the FeedReaders. 
  """
  use GenServer

  alias TLRSS.Item

  #######
  # API #
  #######

  @spec start_link([Item.t], [name: atom]) :: {:ok, pid}
  def start_link(init_items \\ [], opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, init_items, opts)
  end

  @spec items(pid) :: [Item.t]
  def get_items(pid \\ __MODULE__) do
    GenServer.call(pid, :get_items)
  end

  @spec add_items([Item.t], pid) :: :ok
  def add_items(items_to_add, pid \\ __MODULE__) do
    GenServer.call(pid, {:add_items, items_to_add})
  end

  @spec remove_items([Item.t], pid) :: :ok
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

  def handle_call(:items, _from, current_items) do
    {:reply, current_items, current_items}
  end

  def handle_call({:add_items, items_to_add}, _from, current_items) do
    new_items = _new_items(current_items, items_to_add)
    new_current_items = _add_items(current_items, items_to_add)
    {:reply, new_items, new_current_items}
  end

  def handle_cast({:remove_items, items_to_remove}, current_items) do
    {:noreply, _remove_items(current_items, items_to_remove)}
  end
end
