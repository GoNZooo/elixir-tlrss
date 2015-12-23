defmodule TLRSSTest do
  use ExUnit.Case
  doctest TLRSS

  test "add items" do
    {:ok, pid} = TLRSS.ItemBucket.start_link
    items = [42,1337,13,5,23]

    TLRSS.ItemBucket.add_items pid, items
    {:items, is} = TLRSS.ItemBucket.get_items pid

    assert is == items
  end

  test "seen_item? after init" do
    item = %TLRSS.Item{tlid: "tlid", name: "name", link: "link"}
    {:ok, pid} = TLRSS.ItemBucket.start_link([item])

    {:seen, i} = TLRSS.ItemBucket.seen_item? pid, item
    assert i == item
  end

  test "seen_item? after adding item" do
    {:ok, pid} = TLRSS.ItemBucket.start_link
    item = %TLRSS.Item{tlid: "tlid", name: "name", link: "link"}

    TLRSS.ItemBucket.add_item pid, item
    {:seen, i} = TLRSS.ItemBucket.seen_item? pid, item
    assert i == item
  end

  test "remove item" do
    {:ok, pid} = TLRSS.ItemBucket.start_link([1,2,3,4,5])

    TLRSS.ItemBucket.remove_item pid, 2
    TLRSS.ItemBucket.remove_item pid, 4

    {:items, items} = TLRSS.ItemBucket.get_items pid
    assert items == [1,3,5]
  end

  test "remove items" do
    {:ok, pid} = TLRSS.ItemBucket.start_link([1,2,3,4,5])

    TLRSS.ItemBucket.remove_items(pid, [2,4])

    {:items, items} = TLRSS.ItemBucket.get_items pid
    assert items == [1,3,5]
  end

  test "remove matching" do
    {:ok, pid} = TLRSS.ItemBucket.start_link([1,2,3,4,5])

    TLRSS.ItemBucket.remove_matching(pid, fn n -> rem(n, 2) == 0 end)

    {:items, items} = TLRSS.ItemBucket.get_items pid
    assert items == [1,3,5]
  end

  test "add items, some already present" do
    {:ok, pid} = TLRSS.ItemBucket.start_link([1,2,3,4,5])

    {{:ok, new_items},
     {:seen, seen_items}} = TLRSS.ItemBucket.add_items pid, [2,3, 42, 1337]

    assert new_items == [42, 1337]
    assert seen_items == [2,3]
  end
end
