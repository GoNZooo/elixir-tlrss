defmodule TLRSS.FeedReader.RSS do
  @moduledoc"""
  Handles the retrieval and minimal parsing of RSS feeds, using FeederEx.
  """
  alias TLRSS.Item

  @spec get_entries(String.t) :: [FeederEx.Entry.t]
  @doc"""
  Fetches the specified RSS feed and returns all entries from it.

  Will return {:error, reason} upon error and {:entries, [entry]} upon
  success.

  The error reason will be unpacked before returning it, meaning it can be
  handled without consideration of %HTTPoison.Error{}.
  """
  def get_entries(rss_url \\ Application.get_env(:tlrss, :rss_url)) do
    response = HTTPoison.get(rss_url, [{"Accept-Encoding:", "utf-8"}])
    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
        {:ok, feed, _} = FeederEx.parse(body)
        {:entries, feed.entries}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @spec entry_to_item(FeederEx.Entry.t) :: Item.t
  @doc"Converts a %FeederEx.Entry{} to an %Item{}"
  def entry_to_item(%FeederEx.Entry{title: name, id: id, link: link}) do
    %Item{name: name, id: id, link: link}
  end
end
