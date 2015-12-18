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
end
