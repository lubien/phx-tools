defmodule PhxTools.PhxGenFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhxTools.PhxGen` context.
  """

  @doc """
  Generate a phx_contex.
  """
  # def phx_contex_fixture(attrs \\ %{}) do
  #   {:ok, phx_contex} =
  #     attrs
  #     |> Enum.into(%{
  #       context_name: "some context_name",
  #       model_name: "some model_name",
  #       table_name: "some table_name"
  #     })
  #     |> PhxTools.PhxGen.create_phx_contex()

  #   phx_contex
  # end

  @doc """
  Generate a phx_field.
  """
  # def phx_field_fixture(attrs \\ %{}) do
  #   {:ok, phx_field} =
  #     attrs
  #     |> Enum.into(%{
  #       array: true,
  #       enum_options: ["option1", "option2"],
  #       redact: true,
  #       referenced_table: "some referenced_table",
  #       type: "some type",
  #       unique: true
  #     })
  #     |> PhxTools.PhxGen.create_phx_field()

  #   phx_field
  # end
end
