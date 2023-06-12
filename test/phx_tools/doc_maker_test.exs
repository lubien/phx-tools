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

      assert DocMaker.list_assigns_in_heex("""
      <div phx-feedback-for={@name}>
        <.label for={@id}><%= @label %></.label>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 dark:bg-white/5 dark:text-white dark:ring-white/10",
            "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 dark:phx-no-feedback:border-[#6b7280] dark:phx-no-feedback:focus:ring-indigo-500 dark:ring-1 dark:ring-inset dark:ring-white/10 dark:border-0 dark:focus:ring-2 dark:focus:ring-inset",
            @errors == [] && "border-zinc-300 focus:border-zinc-400",
            @errors != [] && "border-rose-400 focus:border-rose-400"
          ]}
          {@rest}
        />
        <.error :for={msg <- @errors}><%= msg %></.error>
      </div>
      """) == [:errors, :id, :label, :name, :rest, :type, :value]
    end
  end
end
