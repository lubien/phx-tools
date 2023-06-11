defmodule PhxToolsWeb.ContextGeneratorLive do
  use PhxToolsWeb, :live_view

  alias PhxTools.PhxGen
  alias PhxTools.PhxGen.{PhxContex, PhxField}

  def render(assigns) do
    ~H"""
    <div>
      <textarea class="w-full mt-12 bg-[#dedede] dark:disabled:bg-gray-600 dark:text-white border-none" disabled rows="3"><%= @generated_command %></textarea>

      <.form for={@form} phx-change="update_form">
        <div class="mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6">
          <div class="sm:col-span-2">
            <.input label="Context name" field={@form[:context_name]} />
          </div>
          <div class="sm:col-span-2">
            <.input label="Model name" field={@form[:model_name]} />
          </div>
          <div class="sm:col-span-2">
            <.input label="Table name" field={@form[:table_name]} />
          </div>
        </div>

        <div class="overflow-hidden rounded-md shadow mt-4">
          <ul role="list" class="">
            <.inputs_for :let={ff} field={@form[:fields]}>
              <li class="py-4">
                <.divider_with_title_and_button>
                  <:title>Field</:title>
                  <:button>
                    <button type="button" phx-click={JS.dispatch("click", to: "#remove-field-#{ff.id}")} class="inline-flex items-center gap-x-1.5 rounded-full bg-white px-3 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50">
                      <.icon name="hero-x-mark-solid" />
                      <span>Remove</span>
                    </button>
                    <input id={"remove-field-#{ff.id}"} type="checkbox" name="phx_contex[fields_drop][]" value={ff.index} class="hidden" />
                  </:button>
                </.divider_with_title_and_button>

                <input type="hidden" name="phx_contex[fields_sort][]" value={ff.index} />
                <div class={"mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-#{if ff[:type].value == "references", do: "3", else: 2}"}>
                  <div class="sm:col-span-auto">
                    <.input type="text" field={ff[:name]} label="Field name" />
                  </div>
                  <div class="sm:col-span-auto">
                    <.input type="select" field={ff[:type]} options={@type_select_options} value={ff[:type].value || "string"} label="Field type" />
                  </div>
                  <%= if ff[:type].value == "references" do %>
                    <div class="sm:col-span-auto">
                      <.input type="text" field={ff[:referenced_table]} label="Referenced table" />
                    </div>
                  <% end %>
                </div>

                <%= if ff[:type].value == "enum" do %>
                  <.inputs_for :let={eof} field={ff[:enum_options]}>
                    <li class="ml-12 px-6 py-4">
                      <.divider_with_title_and_button>
                        <:title>Enum option</:title>
                        <:button>
                          <button type="button" phx-click={JS.dispatch("click", to: "#remove-enum-option-#{eof.id}")} class="inline-flex items-center gap-x-1.5 rounded-full bg-white px-3 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50">
                            <.icon name="hero-x-mark-solid" />
                            <span>Remove</span>
                          </button>
                          <input id={"remove-enum-option-#{eof.id}"} type="checkbox" name={"phx_contex[fields][#{ff.index}][enum_options_drop][]"} value={eof.index} class="hidden" />
                        </:button>
                      </.divider_with_title_and_button>

                      <input type="hidden" name={"phx_contex[fields][#{ff.index}][enum_options_sort][]"} value={eof.index} />
                      <.input type="text" field={eof[:name]} />
                    </li>
                  </.inputs_for>

                  <div class="ml-12 px-6 py-4">
                    <.divider_with_button>
                      <:button>
                        <button type="button" phx-click={JS.dispatch("click", to: "#add-enum-option-#{ff.id}")} class="inline-flex items-center gap-x-1.5 rounded-full bg-white px-3 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50">
                          <.icon name="hero-x-plus-solid" />
                          Add enum option
                        </button>
                        <input id={"add-enum-option-#{ff.id}"} type="checkbox" name={"phx_contex[fields][#{ff.index}][enum_options_sort][]"} class="hidden" />
                      </:button>
                    </.divider_with_button>
                  </div>

                  <input type="hidden" name={"phx_contex[fields][#{ff.index}][enum_options_drop][]"} />
                <% end %>

                <div class="mt-6 space-y-6">
                  <div class="relative flex gap-x-3">
                    <div class="flex h-6 items-center">
                      <.input type="checkbox" field={ff[:unique]} />
                    </div>
                    <div class="text-sm leading-6">
                      <.label for={ff[:unique].id}>Unique field?</.label>
                      <p class="text-gray-400">Rows cannot have duplicated values of this field</p>
                    </div>
                  </div>
                  <div class="relative flex gap-x-3">
                    <div class="flex h-6 items-center">
                      <.input type="checkbox" field={ff[:redact]} />
                    </div>
                    <div class="text-sm leading-6">
                      <.label for={ff[:redact].id}>Redact field?</.label>
                      <p class="text-gray-400">Hide this field from inspection (useful for passwords and tokens)</p>
                    </div>
                  </div>
                  <%= if !Enum.member?(["array", "references"], ff[:type].value) do %>
                    <div class="relative flex gap-x-3">
                      <div class="flex h-6 items-center">
                        <.input type="checkbox" field={ff[:array]} />
                      </div>
                      <div class="text-sm leading-6">
                        <.label for={ff[:array].id}>Array field?</.label>
                        <p class="text-gray-400">Store this field as a list of `Field type` inside your database</p>
                      </div>
                    </div>
                  <% end %>
                </div>
              </li>
            </.inputs_for>
          </ul>
        </div>

        <.divider_with_button>
          <:button>
            <button type="button" phx-click={JS.dispatch("click", to: "#add-field")} class="inline-flex items-center gap-x-1.5 rounded-full bg-white px-3 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50">
              <.icon name="hero-x-plus-solid" />
              Add field
            </button>
            <input id="add-field" type="checkbox" name={"phx_contex[fields_sort][]"} class="hidden" />
          </:button>
        </.divider_with_button>

        <input type="hidden" name="phx_contex[fields_drop][]" />
      </.form>
    </div>
    """
  end

  def handle_params(params, _url, socket) do
    type_select_options =
      ~w(string integer float decimal boolean map array references text date time time_usec naive_datetime naive_datetime_usec utc_datetime utc_datetime_usec uuid binary enum datetime)
      |> Enum.sort()

    attrs =
      if params["phx_contex"] do
        params["phx_contex"]
      else
        %{
          context_name: "Blog",
          model_name: "Post",
          table_name: "posts",
          fields: [
            %{name: "name", type: "string"},
            %{
              name: "status",
              type: "enum",
              enum_options: [%{name: "draft"}, %{name: "published"}, %{name: "deleted"}]
            }
          ]
        }
      end

    {:noreply,
     socket
     |> update_form_assigns(attrs)
     |> assign(type_select_options: type_select_options)}
  end

  def handle_event("update_form", %{"phx_contex" => attrs}, socket) do
    params = %{"phx_contex" => attrs}
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  def update_form_assigns(socket, attrs) do
    changeset = PhxGen.change_phx_contex(%PhxContex{}, attrs)
    form = to_form(changeset)
    generated_command = PhxGen.generate_command(changeset)

    socket
    |> assign(changeset: changeset, form: form, generated_command: generated_command)
  end
end
