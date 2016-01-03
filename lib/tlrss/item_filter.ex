defmodule TLRSS.ItemFilter do
  use GenServer

  #######
  # API #
  #######

  def start_link(filters \\ Application.get_env(:tlrss, :filters),
                 opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, filters, opts)
  end

  def matches?(items, pid \\ __MODULE__) do
    GenServer.call(pid, {:matches?, items})
  end

  def get_filters(pid \\ __MODULE__) do
    GenServer.call(pid, :get_filters)
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

  def handle_call({:matches?, items}, _from, filters) do
    matches = Enum.filter(items, &(any_matches?(&1, filters)))
    {:reply, {:matches, matches}, filters}
  end

  def handle_call(:get_filters, _from, filters) do
    {:reply, {:filters, filters}, filters}
  end
end
