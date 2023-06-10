defmodule PhxTools.PhxGen do
  @moduledoc """
  The PhxGen context.
  """

  alias PhxTools.Repo

  alias PhxTools.PhxGen.PhxContex

  def generate_command(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.apply_changes(changeset)
    |> generate_command()
  end

  def generate_command(%PhxContex{context_name: context_name, model_name: model_name, table_name: table_name} = _phx_context) do
    "mix phx.gen.context #{context_name} #{model_name} #{table_name}"
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
end
