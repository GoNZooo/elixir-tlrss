defmodule TLRSS.FeedReader.RSS do
  @moduledoc"""
  Handles the retrieval and minimal parsing of RSS feeds, using FeederEx.
  """
  alias TLRSS.Item

  @spec get_entries(String.t) :: [FeederEx.Entry.t]
  @doc"Fetches the specified RSS feed and returns all entries from it."
  def get_entries(rss_url \\ Application.get_env(:tlrss, :rss_url)) do
    response = HTTPoison.get(rss_url, [{"Accept-Encoding:", "utf-8"}])
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(rss_url)
    {:ok, feed, _} = FeederEx.parse body 
    feed.entries
  end

  @spec entry_to_item(FeederEx.Entry.t) :: Item.t
  @doc"Converts a %FeederEx.Entry{} to an %Item{}"
  def entry_to_item(%FeederEx.Entry{title: name, id: id, link: link}) do
    %Item{name: name, id: id, link: link}
  end
end
