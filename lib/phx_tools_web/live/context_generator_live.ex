defmodule PhxToolsWeb.ContextGeneratorLive do
  use PhxToolsWeb, :live_view

  alias PhxTools.PhxGen
  alias PhxTools.PhxGen.{PhxContex, PhxField}

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-change="update_form">
        <.input label="Context name" field={@form[:context_name]} />
        <.input label="Model name" field={@form[:model_name]} />
        <.input label="Table name" field={@form[:table_name]} />

        <textarea class="w-full mt-12 bg-[#dedede] border-none" disabled rows="3"><%= @generated_command %></textarea>
      </.form>
    </div>
    """
  end

  def handle_params(_params, _url, socket) do
    attrs = %{
      context_name: "Blog",
      model_name: "Post",
      table_name: "posts",
      fields: [
        %{name: "name", type: "string"}
      ]
    }

    {:noreply,
     socket
     |> update_form_assigns(attrs)}
  end

  def handle_event("update_form", %{"phx_contex" => attrs}, socket) do
    {:noreply, update_form_assigns(socket, attrs)}
  end

  def update_form_assigns(socket, attrs) do
    changeset = PhxGen.change_phx_contex(%PhxContex{}, attrs)
    form = to_form(changeset)
    generated_command = PhxGen.generate_command(changeset)

    socket
    |> assign(changeset: changeset, form: form, generated_command: generated_command)
  end
end
