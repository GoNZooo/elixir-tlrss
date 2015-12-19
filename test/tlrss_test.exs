defmodule TLRSSTest do
  use ExUnit.Case
  doctest TLRSS

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "seen_item? is true after adding item" do
    {:ok, repo} = TLRSS.Repo.start_link
    item = %TLRSS.Item{tlid: "tlid", name: "name", link: "link"}

    TLRSS.Repo.add_item repo, item
    {:seen, i} = TLRSS.Repo.seen_item? repo, item
    assert i == item
  end
end
