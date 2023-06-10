defmodule PhxTools.PhxGen.PhxField do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "phx_fields" do
    field :name, :string
    field :array, :boolean, default: false
    field :enum_options, {:array, :string}
    field :redact, :boolean, default: false
    field :referenced_table, :string
    field :type, :string
    field :unique, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(phx_field, attrs) do
    phx_field
    |> cast(attrs, [:name, :type, :referenced_table, :redact, :array, :unique, :enum_options])
    |> validate_required([:name])
  end
end
