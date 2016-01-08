defmodule TLRSS.FeedReader.Supervisor do
  use Supervisor

  def start_link(feeds \\ Application.get_env(:tlrss, :rss_feeds),
                 opts \\ [name: __MODULE__]) do
    Supervisor.start_link(__MODULE__, feeds, opts)
  end

  def init(feeds) do
    children = Enum.map(feeds,
      fn {name, url} ->
        worker(TLRSS.FeedReader, [url], name: name)
      end)

      supervise(children, strategy: :one_for_one)
  end
end
