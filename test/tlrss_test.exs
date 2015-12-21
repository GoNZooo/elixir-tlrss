defmodule TLRSSTest do
  use ExUnit.Case
  doctest TLRSS

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "seen_item? is true after adding item" do
    {:ok, pid} = TLRSS.ItemBucket.start_link([])
    item = %TLRSS.Item{tlid: "tlid", name: "name", link: "link"}

    TLRSS.ItemBucket.add_item pid, item
    {:seen, i} = TLRSS.ItemBucket.seen_item? pid, item
    assert i == item
  end

  test "add items, items are the same after fetch" do
    {:ok, pid} = TLRSS.ItemBucket.start_link([])
    items = [42,1337,13,5,23]

    TLRSS.ItemBucket.add_items pid, items
    {:items, is} = TLRSS.ItemBucket.get_items pid

    assert is == items
  end

  test "add items, remove item and verify correctness" do
    {:ok, pid} = TLRSS.ItemBucket.start_link([1,2,3,4,5])

    TLRSS.ItemBucket.remove_item pid, 2
    TLRSS.ItemBucket.remove_item pid, 4

    {:items, items} = TLRSS.ItemBucket.get_items pid
    assert is = [1,3,5]
  end
end
