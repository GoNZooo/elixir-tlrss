defmodule TLRSS.ItemFilter do
  use GenServer

  #######
  # API #
  #######

  def start_link(filters \\ Application.get_env(:tlrss, :filters),
                 opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, filters, opts)
  end

  def filter(items, pid \\ __MODULE__) do
    GenServer.cast(pid, {:filter, items})
  end

  def get_filters(pid \\ __MODULE__) do
    GenServer.call(pid, :get_filters)
  end

  def set_filters(new_filters, pid \\ __MODULE__) do
    GenServer.cast(pid, {:set_filters, new_filters})
  end

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

  def handle_cast({:filter, items}, filters) do
    matches = Enum.filter(items, &(any_matches?(&1, filters)))

    matches
    |> Enum.each(&(TLRSS.Download.download(&1)))

    {:noreply, filters}
  end

  def handle_cast({:set_filters, new_filters}, _filters) do
    {:noreply, new_filters}
  end

  def handle_cast({:add_filter, new_filter}, filters) do
    {:noreply, [new_filter | filters]}
  end

  def handle_call(:get_filters, _from, filters) do
    {:reply, {:filters, filters}, filters}
  end
end
