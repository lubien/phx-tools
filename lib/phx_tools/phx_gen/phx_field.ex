defmodule PhxTools.PhxGen.PhxField do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "phx_fields" do
    field :name, :string
    field :type, :string
    field :referenced_table, :string
    field :array, :boolean, default: false
    field :redact, :boolean, default: false
    field :unique, :boolean, default: false

    embeds_many :enum_options, EnumOption, on_replace: :delete do
      field :name, :string
    end

    timestamps()
  end

  @doc false
  def changeset(phx_field, attrs) do
    phx_field
    |> cast(attrs, [:name, :type, :referenced_table, :redact, :array, :unique])
    |> cast_embed(:enum_options,
      with: &enum_options_changeset/2,
      sort_param: :enum_options_sort,
      drop_param: :enum_options_drop
    )
    |> validate_required([:name])
  end

  @doc false
  def enum_options_changeset(enum_option, attrs) do
    enum_option
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
