defmodule PhxTools.PhxGenTest do
  use PhxTools.DataCase

  alias PhxTools.PhxGen

  describe "phx_contexts" do
    alias PhxTools.PhxGen.PhxContex

    import PhxTools.PhxGenFixtures

    @valid_attrs %{context_name: "Blog", model_name: "Post", table_name: "posts"}
    @invalid_attrs %{context_name: nil, model_name: nil, table_name: nil}

    test "generate basic command" do
      assert %Ecto.Changeset{valid?: true} = changeset = PhxGen.change_phx_contex(%PhxContex{}, @valid_attrs)
      command = PhxGen.generate_command(changeset)
      assert command =~ "mix phx.gen.context Blog Post posts"
    end
  end
end
