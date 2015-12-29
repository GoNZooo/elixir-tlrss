defmodule ItemBucketTest do
  use ExUnit.Case
  doctest TLRSS.ItemBucket

  import TLRSS.ItemBucket,
  only: [
    start_link: 0,
    start_link: 1,
    add_items: 2,
    get_items: 1,
    remove_items: 2,
    remove_matching: 2,

  ]

  test "add items" do
    {:ok, pid} = start_link
    items = [42, 1337, 13, 5, 23]

    add_items pid, items
    {:items, is} = get_items pid

    assert is == items
  end

  test "remove items" do
    {:ok, pid} = start_link [1, 2, 3, 4, 5]

    remove_items pid, [2, 4] 

    {:items, items} = get_items pid
    assert items == [1, 3, 5]
  end

  test "remove matching" do
    {:ok, pid} = start_link [1, 2, 3, 4, 5]

    remove_matching pid, &(rem(&1, 2) == 0)

    {:items, items} = get_items pid
    assert items == [1, 3, 5]
  end

  test "add items, some already present" do
    {:ok, pid} = start_link [1, 2, 3, 4, 5]
    is = [2, 3, 42, 1337]

    {:ok, new_items} = add_items pid, is

    assert new_items == [42, 1337]
  end

  test "add items, all already present" do
    {:ok, pid} = start_link [1, 2, 3, 4, 5]
    is = [2, 3, 1, 4, 5]

    {:ok, new_items} = add_items pid, is

    assert new_items == []
  end

  test "add items, none already present" do
    {:ok, pid} = start_link [1,2,3,4]
    is = [42, 1337, 5, 23]

    {:ok, new_items} = add_items pid, is

    assert new_items == [42, 1337, 5, 23]
  end
end
