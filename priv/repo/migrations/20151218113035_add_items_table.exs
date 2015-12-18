defmodule TLRSS.Repo.Migrations.AddItemsTable do
  use Ecto.Migration

  def up do
    create table(:items) do
      add :tlid, :string, null: false
      add :name, :string, null: false
      add :link, :string, null: false
      add :downloaded, :boolean, default: false

      timestamps
    end
  end

  def down do
    drop table(:items)
  end
end
