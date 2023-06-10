defmodule PhxTools.PhxGen.PhxContex do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "phx_contexts" do
    field :context_name, :string
    field :model_name, :string
    field :table_name, :string

    timestamps()
  end

  @doc false
  def changeset(phx_contex, attrs) do
    phx_contex
    |> cast(attrs, [:context_name, :model_name, :table_name])
    |> validate_required([:context_name, :model_name, :table_name])
  end
end
