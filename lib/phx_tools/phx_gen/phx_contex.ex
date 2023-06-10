defmodule PhxTools.PhxGen.PhxContex do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "phx_contexts" do
    field :context_name, :string
    field :model_name, :string
    field :table_name, :string

    embeds_many :fields, PhxTools.PhxGen.PhxField, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(phx_contex, attrs) do
    phx_contex
    |> cast(attrs, [:context_name, :model_name, :table_name])
    |> cast_embed(:fields,
      with: &PhxTools.PhxGen.PhxField.changeset/2,
      sort_param: :fields_sort,
      drop_param: :fields_drop
    )
    |> validate_required([:context_name, :model_name, :table_name])
  end
end
