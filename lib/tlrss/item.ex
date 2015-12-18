defmodule TLRSS.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field(:tlid, :string)
    field(:name, :string)
    field(:link, :string)
    field(:downloaded, :boolean, default: false)
  end

  @required_fields ~w(tlid name link)
  @optional_fields ~w(downloaded)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:id)
    |> validate_length(:tlid, min: 1)
    |> validate_length(:name, min: 1)
    |> validate_length(:link, min: 1)
  end
end
