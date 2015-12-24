defmodule TLRSSTest do
  use ExUnit.Case
  doctest TLRSS

  alias TLRSS.ItemBucket

  test "add items" do
    {:ok, pid} = ItemBucket.start_link
    items = [42, 1337, 13, 5, 23]

    ItemBucket.add_items pid, items
    {:items, is} = ItemBucket.get_items pid

    assert is == items
  end

  test "seen_item? after init" do
    item = %TLRSS.Item{tlid: "tlid", name: "name", link: "link"}
    {:ok, pid} = ItemBucket.start_link([item])

    {:seen, i} = ItemBucket.seen_item? pid, item
    assert i == item
  end

  test "seen_item? after adding item" do
    {:ok, pid} = ItemBucket.start_link
    item = %TLRSS.Item{tlid: "tlid", name: "name", link: "link"}

    ItemBucket.add_item pid, item
    {:seen, i} = ItemBucket.seen_item? pid, item
    assert i == item
  end

  test "remove item" do
    {:ok, pid} = ItemBucket.start_link([1,2,3,4,5])

    ItemBucket.remove_item pid, 2
    ItemBucket.remove_item pid, 4

    {:items, items} = ItemBucket.get_items pid
    assert items == [1, 3, 5]
  end

  test "remove items" do
    {:ok, pid} = ItemBucket.start_link([1, 2, 3, 4, 5])

    ItemBucket.remove_items(pid, [2, 4])

    {:items, items} = ItemBucket.get_items pid
    assert items == [1, 3, 5]
  end

  test "remove matching" do
    {:ok, pid} = ItemBucket.start_link([1, 2, 3, 4, 5])

    ItemBucket.remove_matching(pid, fn n -> rem(n, 2) == 0 end)

    {:items, items} = ItemBucket.get_items pid
    assert items == [1, 3, 5]
  end

  test "add items, some already present" do
    {:ok, pid} = ItemBucket.start_link([1, 2, 3, 4, 5])
    is = [2,3, 42, 1337]

    {{:ok, new_items}, {:seen, seen_items}} = ItemBucket.add_items pid, is

    assert new_items == [42, 1337]
    assert seen_items == [2, 3]
  end

  test "add items, all already present" do
    {:ok, pid} = ItemBucket.start_link([1, 2, 3, 4, 5])
    is = [2, 3, 1, 4, 5]

    {{:ok, new_items}, {:seen, seen_items}} = ItemBucket.add_items pid, is

    assert new_items == []
    assert seen_items == [2, 3, 1, 4, 5]
  end

  test "add items, none already present" do
    {:ok, pid} = ItemBucket.start_link([1,2,3,4])
    is = [42, 1337, 5, 23]

    {{:ok, new_items}, {:seen, seen_items}} = ItemBucket.add_items pid, is

    assert new_items == [42, 1337, 5, 23]
    assert seen_items == []
  end
end
