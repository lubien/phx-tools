defmodule PhxTools.DocMakerTest do
  use PhxTools.DataCase

  alias PhxTools.DocMaker

  describe "phx_contexts" do
    test "knows how to find assigns" do
      assert DocMaker.list_assigns_in_heex("""
      <div>
        <.magic>a</.magic>

        <%= @meu_assign %>
        <%= @a + @b + c %>
        <div {@attrs}>a</div>

        <Foo.Bar.magic foo={@bar} baz={@a + @b + @c + @d + e}>
          <:meu_slot></:meu_slot>
        </Foo.Bar.magic>
      </div>
      """) == [:a, :attrs, :b, :bar, :c, :d, :meu_assign]
    end
  end
end
