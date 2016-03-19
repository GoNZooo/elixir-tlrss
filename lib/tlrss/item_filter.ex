defmodule TLRSS.ItemFilter do
  @moduledoc"""
  Module to filter incoming items from the ItemBucket, to determine
  if these should be sent for downloading. Internally, keeps a state
  of all registered filters to apply to each incoming item.
  """
  use GenServer
  alias TLRSS.Item

  #######
  # API #
  #######

  @spec start_link([Regex.t], [name: atom]) :: {:ok, pid}
  def start_link(filters \\ Application.get_env(:tlrss, :filters),
                 opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, filters, opts)
  end

  @spec filter([Item.t], pid) :: :ok
  def filter(items, pid \\ __MODULE__) do
    GenServer.call(pid, {:filter, items})
  end

  def get_filters(pid \\ __MODULE__) do
    GenServer.call(pid, :get_filters)
  end

  @spec set_filters([Regex.t], pid) :: :ok
  def set_filters(new_filters, pid \\ __MODULE__) do
    GenServer.cast(pid, {:set_filters, new_filters})
  end

  @spec add_filter(Regex.t, pid) :: :ok
  def add_filter(new_filter, pid \\ __MODULE__) do
    GenServer.cast(pid, {:add_filter, new_filter})
  end

  ############
  # Internal #
  ############

  defp any_matches?(item, filters) do
    Enum.any? filters, &(Regex.match?(&1, item.name))
  end

  def init(filters) do
    {:ok, filters}
  end

  def handle_call({:filter, items}, _from, filters) do
    matches = Enum.filter(items, &(any_matches?(&1, filters)))
    {:reply, matches, filters}
  end

  def handle_call(:get_filters, _from, filters) do
    {:reply, {:filters, filters}, filters}
  end

  def handle_cast({:set_filters, new_filters}, _filters) do
    {:noreply, new_filters}
  end

  def handle_cast({:add_filter, new_filter}, filters) do
    {:noreply, [new_filter | filters]}
  end

end
