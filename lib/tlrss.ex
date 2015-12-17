defmodule TLRSS do
  def rss_data do
    rss_url = Application.get_env(:tlrss, :rss_url)
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(rss_url)
    {:ok, feed, _} = FeederEx.parse body 
    feed
  end

  def rss_entries do
    rss_url = Application.get_env(:tlrss, :rss_url)
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(rss_url)
    {:ok, feed, _} = FeederEx.parse body 
    feed.entries
  end
end
