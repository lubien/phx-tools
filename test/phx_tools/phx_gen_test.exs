defmodule PhxTools.PhxGenTest do
  use PhxTools.DataCase

  alias PhxTools.PhxGen

  describe "phx_contexts" do
    alias PhxTools.PhxGen.PhxContex

    import PhxTools.PhxGenFixtures

    @valid_attrs %{context_name: "Blog", model_name: "Post", table_name: "posts", fields: [
      %{name: "name", type: "string"}
    ]}

    test "generate basic command" do
      assert %Ecto.Changeset{valid?: true} = changeset = PhxGen.change_phx_contex(%PhxContex{}, @valid_attrs)
      command = PhxGen.generate_command(changeset)
      assert command =~ "mix phx.gen.context Blog Post posts"
      assert command =~ "name:string"
    end
  end
end
