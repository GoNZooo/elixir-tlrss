defmodule ItemBucketTest do
  use ExUnit.Case
  doctest TLRSS.ItemBucket

  alias TLRSS.Item
  import TLRSS.ItemBucket,
  only: [
    start_link: 0,
    start_link: 1,
    start_link: 2,
    get_items: 1,
    add_items: 2,
    remove_items: 2,
  ]

  test "init without items" do
    {:ok, pid} = start_link([], [name: :test_bucket])

    assert get_items(pid) == {:items, %{}}
  end

  test "init with items" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link [item_a, item_b], [name: :test_bucket]

    assert get_items(pid) == {:items,
                              %{item_a.name => item_a,
                               item_b.name => item_b}}
  end

  test "add items" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link([], [name: :test_bucket])

    {:new_items, _} = add_items [item_a, item_b], pid

    assert get_items(pid) == {:items,
                              %{item_a.name => item_a,
                               item_b.name => item_b}}
  end

  test "add two items" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link([], [name: :test_bucket])

    {:new_items, [^item_a]} = add_items [item_a], pid
    {:new_items, [^item_b]} = add_items [item_b], pid

    assert get_items(pid) == {:items,
                              %{item_a.name => item_a,
                               item_b.name => item_b}}
  end

  test "add two items, remove both at once" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link([], [name: :test_bucket])

    {:new_items, _} = add_items [item_a, item_b], pid
    remove_items [item_a, item_b], pid

    assert get_items(pid) == {:items, %{}}
  end

  test "add two items, remove separately" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link([], [name: :test_bucket])

    {:new_items, _} = add_items [item_a, item_b], pid

    remove_items [item_a], pid
    assert get_items(pid) == {:items, %{item_b.name => item_b}}

    remove_items [item_b], pid
    assert get_items(pid) == {:items, %{}}
  end

  test "add items, add same items again" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link([], [name: :test_bucket])

    {:new_items, _} = add_items [item_a, item_b], pid
    {:new_items, new_items_b} = add_items [item_a, item_b], pid

    assert new_items_b == []
  end
end
