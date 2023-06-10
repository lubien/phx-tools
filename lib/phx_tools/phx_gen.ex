defmodule PhxTools.PhxGen do
  @moduledoc """
  The PhxGen context.
  """

  alias PhxTools.PhxGen.PhxContex
  alias PhxTools.PhxGen.PhxField

  def generate_command(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.apply_changes(changeset)
    |> generate_command()
  end

  def generate_command(%PhxContex{context_name: context_name, model_name: model_name, table_name: table_name, fields: fields} = _phx_context) do
    "mix phx.gen.context #{context_name} #{model_name} #{table_name} #{generate_field_commands(fields)}"
  end

  defp generate_field_commands(fields) do
    fields
    |> Enum.map(&generate_field/1)
    |> Enum.join(" ")
  end

  defp generate_field(%PhxField{name: name, type: type}) do
    "#{name}:#{type}"
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking phx_contex changes.

  ## Examples

      iex> change_phx_contex(phx_contex)
      %Ecto.Changeset{data: %PhxContex{}}

  """
  def change_phx_contex(%PhxContex{} = phx_contex, attrs \\ %{}) do
    PhxContex.changeset(phx_contex, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking phx_field changes.

  ## Examples

      iex> change_phx_field(phx_field)
      %Ecto.Changeset{data: %PhxField{}}

  """
  def change_phx_field(%PhxField{} = phx_field, attrs \\ %{}) do
    PhxField.changeset(phx_field, attrs)
  end
end
