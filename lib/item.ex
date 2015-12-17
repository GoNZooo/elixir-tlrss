defmodule TLRSS.Item do
  use Ecto.Schema

  schema "item" do
    field :id,
    field :name,
    field :link,
    field :seen, :boolean, default: false
  end
end
