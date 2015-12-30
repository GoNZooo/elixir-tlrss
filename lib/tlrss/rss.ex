defmodule TLRSS.RSS do
  alias TLRSS.Item

  def get_entries(rss_url \\ Application.get_env(:tlrss, :rss_url)) do
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(rss_url)
    {:ok, feed, _} = FeederEx.parse body 
    feed.entries
  end

  def entry_to_item(%FeederEx.Entry{title: name, id: tlid, link: link}) do
    %Item{name: name, tlid: tlid, link: link}
  end
end
