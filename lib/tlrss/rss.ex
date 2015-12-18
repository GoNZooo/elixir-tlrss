defmodule TLRSS.RSS do
  require Logger

  def data do
    rss_url = Application.get_env(:tlrss, :rss_url)
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(rss_url)
    {:ok, feed, _} = FeederEx.parse body 
    feed
  end

  def entries do
    rss_url = Application.get_env(:tlrss, :rss_url)
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(rss_url)
    {:ok, feed, _} = FeederEx.parse body 
    feed.entries
  end

  defp add_entry(e) do
    changeset = TLRSS.Item.changeset %TLRSS.Item{}, %{tlid: e.id,
                                                      name: e.title,
                                                      link: e.link}
    TLRSS.Repo.insert changeset
  end

  def log_entries(entries) do
    Enum.map entries,
    fn e ->
      case add_entry(e) do
        {:ok, _} ->
          Logger.info "Added #{e.name} [#{e.id}]"
        {:error, changeset} ->
          Logger.info "Could not add #{e.name}"
        Enum.each changeset.errors, fn {f, e} -> Logger.info "#{f}: #{e}" end
      end
    end
  end
end
