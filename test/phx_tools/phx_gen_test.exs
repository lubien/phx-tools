defmodule PhxTools.PhxGenTest do
  use PhxTools.DataCase

  alias PhxTools.PhxGen

  describe "phx_contexts" do
    alias PhxTools.PhxGen.PhxContex

    import PhxTools.PhxGenFixtures

    @valid_context %{context_name: "Blog", model_name: "Post", table_name: "posts"}
    @valid_attrs Map.merge(@valid_context, %{fields: [
      %{name: "name", type: "string"},
      %{name: "is_published", type: "boolean"},
    ]})

    test "generate basic command" do
      assert %Ecto.Changeset{valid?: true} = changeset = PhxGen.change_phx_contex(%PhxContex{}, @valid_attrs)
      command = PhxGen.generate_command(changeset)
      assert command =~ "mix phx.gen.context Blog Post posts"
      assert command =~ "name"
      assert command =~ "is_published:boolean"
    end

    test "generate string" do
      command = PhxGen.generate_command(changeset_for_field(%{
        name: "str_field", type: "string"
      }))
      assert command =~ "str_field"
      refute command =~ ":string"
    end

    test "generate enum" do
      command = PhxGen.generate_command(changeset_for_field(%{
        name: "enum_field", type: "enum", enum_options: [
          %{name: "abc"}, %{name: "def"}
        ]
      }))
      assert command =~ "enum_field:enum:abc:def"
    end

    test "generate references" do
      command = PhxGen.generate_command(changeset_for_field(%{
        name: "ref_field", type: "references", referenced_table: "users"
      }))
      assert command =~ "ref_field:references:users"
    end

    test "generate arrays" do
      command = PhxGen.generate_command(changeset_for_field(%{
        name: "arr_field", array: true, type: "string"
      }))
      assert command =~ "arr_field:array"
      command = PhxGen.generate_command(changeset_for_field(%{
        name: "arr_field", array: true, type: "boolean"
      }))
      assert command =~ "arr_field:array:boolean"
    end

    test "generate redact" do
      command = PhxGen.generate_command(changeset_for_field(%{
        name: "redact_field", redact: true, type: "string"
      }))
      assert command =~ "redact_field:redact"
      command = PhxGen.generate_command(changeset_for_field(%{
        name: "redact_field", redact: true, type: "boolean"
      }))
      assert command =~ "redact_field:boolean:redact"
    end

    test "generate unique" do
      command = PhxGen.generate_command(changeset_for_field(%{
        name: "unique_field", unique: true, type: "string"
      }))
      assert command =~ "unique_field:unique"
      command = PhxGen.generate_command(changeset_for_field(%{
        name: "unique_field", unique: true, type: "boolean"
      }))
      assert command =~ "unique_field:boolean:unique"
    end

    defp changeset_for_field(field) do
      attrs = Map.put(@valid_attrs, :fields, [field])
      PhxGen.change_phx_contex(%PhxContex{}, attrs)
    end
  end
end
