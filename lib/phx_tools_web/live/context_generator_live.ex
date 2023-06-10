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

        <div class="overflow-hidden rounded-md bg-white shadow mt-4">
          <ul role="list" class="divide-y divide-gray-200">
            <.inputs_for :let={ff} field={@form[:fields]}>
              <li class="px-6 py-4">
                <input type="hidden" name="phx_contex[fields_sort][]" value={ff.index} />
                <.input type="text" field={ff[:name]} label="Field name" />
                <.input type="select" field={ff[:type]} options={@type_select_options} label="Field type" />
                <%= if ff[:type].value == "references" do %>
                  <.input type="text" field={ff[:referenced_table]} label="Referenced table" />
                <% end %>

                <%= if ff[:type].value == "enum" do %>
                  <.inputs_for :let={eof} field={ff[:enum_options]}>
                    <li class="ml-12 px-6 py-4">
                      <input type="hidden" name={"phx_contex[fields][#{ff.index}][enum_options_sort][]"} value={eof.index} />
                      <.input type="text" field={eof[:name]} label="Enum option" />

                      <label>
                        <input type="checkbox" name={"phx_contex[fields][#{ff.index}][enum_options_drop][]"} value={eof.index} class="hidden" />
                        <.icon name="hero-x-mark" class="w-6 h-6 relative top-2" />
                      </label>
                    </li>
                  </.inputs_for>

                  <label class="block cursor-pointer my-2">
                    <input type="checkbox" name={"phx_contex[fields][#{ff.index}][enum_options_sort][]"} class="hidden" />
                    Add enum option
                  </label>

                  <input type="hidden" name={"phx_contex[fields][#{ff.index}][enum_options_drop][]"} />
                <% end %>

                <.input type="checkbox" field={ff[:array]} label="Array?" />
                <.input type="checkbox" field={ff[:unique]} label="Unique?" />
                <.input type="checkbox" field={ff[:redact]} label="Redact?" />

                <label>
                  <input type="checkbox" name="phx_contex[fields_drop][]" value={ff.index} class="hidden" />
                  <.icon name="hero-x-mark" class="w-6 h-6 relative top-2" /> delete field
                </label>
              </li>
            </.inputs_for>
          </ul>
        </div>

        <label class="block cursor-pointer my-2">
          <input type="checkbox" name={"phx_contex[fields_sort][]"} class="hidden" />
          Add field
        </label>

        <input type="hidden" name="phx_contex[fields_drop][]" />

        <textarea class="w-full mt-12 bg-[#dedede] border-none" disabled rows="3"><%= @generated_command %></textarea>
      </.form>
    </div>
    """
  end

  def handle_params(_params, _url, socket) do
    type_select_options =
      ~w(string integer float decimal boolean map array references text date time time_usec naive_datetime naive_datetime_usec utc_datetime utc_datetime_usec uuid binary enum datetime)

    attrs = %{
      context_name: "Blog",
      model_name: "Post",
      table_name: "posts",
      fields: [
        %{name: "name", type: "string"},
        %{name: "status", type: "enum", enum_options: [%{name: "draft"}, %{name: "published"}, %{name: "deleted"}]},
      ]
    }

    {:noreply,
     socket
     |> update_form_assigns(attrs)
     |> assign(type_select_options: type_select_options)}
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
