defmodule ItemBucketTest do
  use ExUnit.Case
  doctest TLRSS.ItemBucket

  alias TLRSS.Item
  import TLRSS.ItemBucket,
  only: [
    start_link: 0,
    start_link: 1,
    get_items: 1,
    add_items: 2,
    remove_items: 2,
  ]

  test "init without items" do
    {:ok, pid} = start_link

    assert get_items(pid) == %{}
  end

  test "init with items" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link [item_a, item_b]

    assert get_items(pid) == %{item_a.name => item_a,
                               item_b.name => item_b}
  end

  test "add items" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link

    {:new_items, _} = add_items pid, [item_a, item_b]

    assert get_items(pid) == %{item_a.name => item_a,
                               item_b.name => item_b}
  end

  test "add two items" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link

    {:new_items, [^item_a]} = add_items pid, [item_a]
    {:new_items, [^item_b]} = add_items pid, [item_b]

    assert get_items(pid) == %{item_a.name => item_a,
                               item_b.name => item_b}
  end

  test "add two items, remove both at once" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link

    {:new_items, _} = add_items pid, [item_a, item_b]
    remove_items pid, [item_a, item_b]

    assert get_items(pid) == %{}
  end

  test "add two items, remove separately" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link

    {:new_items, _} = add_items pid, [item_a, item_b]

    remove_items pid, [item_a]
    assert get_items(pid) == %{item_b.name => item_b}

    remove_items pid, [item_b]
    assert get_items(pid) == %{}
  end

  test "add items, add same items again" do
    item_a = %Item{name: "item_a", id: "a_id", link: "a_link"}
    item_b = %Item{name: "item_b", id: "b_id", link: "b_link"}
    {:ok, pid} = start_link

    {:new_items, new_items_a} = add_items pid, [item_a, item_b]
    {:new_items, new_items_b} = add_items pid, [item_a, item_b]

    assert new_items_b == []
  end
end
