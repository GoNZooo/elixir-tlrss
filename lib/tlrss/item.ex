defmodule TLRSS.Item do
  @moduledoc"""
  A struct to hold the most important information about items from the feed.
  The field names should be fairly appropriate for most applications outside
  torrent and TL.
  """
  defstruct [:id, :name, :link]

  @type t :: %TLRSS.Item{id: String.t, name: String.t, link: String.t}

  defimpl Inspect, for: TLRSS.Item do
    def inspect(%TLRSS.Item{id: id, name: name, link: link}, _) do
      short_link = List.last(String.split(link, "/"))
      short_id = List.last(String.split(id, "/"))

      "#{name} [#{short_link}] (#{short_id})"
    end
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%TLRSS.Item{id: id, name: name, link: link}) do
      "#{name} @ #{link} (#{id})"
    end
  end
end
