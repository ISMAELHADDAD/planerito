defmodule PlaneritoWeb.Components.TodoForm do
  use PlaneritoWeb, :component

  def modal_form(assigns) do
    assigns =
      assigns
      |> assign_new(:item, fn -> %Planerito.Events.Event{} end)
      |> assign_new(:changeset, fn -> Planerito.Events.change_event(assigns.item) end)

    ~H"""
    <div class="z-50 fixed inset-0 overflow-y-auto text-black px-3">
      <div class="-z-10 fixed inset-0 bg-white bg-opacity-70 opacity-100"></div>

      <div class="my-12 lg:my-[5%] mx-auto p-6 lg:p-8 box-border max-w-lg rounded bg-blue-200" phx-click-away="deselect_event">
        <.form let={f} for={@changeset} phx-change="edit_event">
          <div class="mb-6 flex justify-between">
            <%= date_input(f, :date, class: "bg-blue-200 text-sm outline-none") %>
            <div class="flex items-center">
              <div class="relative">
                <div class="cursor-pointer" phx-click="delete_event" phx-value-id={@item.id}>Delete</div>
              </div>
            </div>
          </div>

          <div class="relative border-b border-black pr-6">
            <div>
              <%= text_input(f, :title,
                id: "input-edit-form",
                class:
                  Enum.join(
                    [
                      "outline-none text-xl overflow-hidden w-full box-border p-0 border-0 bg-transparent",
                      if(@item.is_completed, do: "line-through opacity-30", else: "")
                    ],
                    " "
                  )
              ) %>
            </div>
            <div class="w-4 h-5 absolute top-1 right-0 cursor-pointer flex justify-end items-center" phx-click="toggle_completed" phx-value-id={@item.id}>
              <%= if @item.is_completed do %>
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" class="w-4 h-4 opacity-30">
                  <path d="M504 256c0 136.967-111.033 248-248 248S8 392.967 8 256 119.033 8 256 8s248 111.033 248 248zM227.314 387.314l184-184c6.248-6.248 6.248-16.379 0-22.627l-22.627-22.627c-6.248-6.249-16.379-6.249-22.628 0L216 308.118l-70.059-70.059c-6.248-6.248-16.379-6.248-22.628 0l-22.627 22.627c-6.248 6.248-6.248 16.379 0 22.627l104 104c6.249 6.249 16.379 6.249 22.628.001z">
                  </path>
                </svg>
              <% else %>
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" class="w-4 h-4">
                  <path d="M256 8C119.033 8 8 119.033 8 256s111.033 248 248 248 248-111.033 248-248S392.967 8 256 8zm0 48c110.532 0 200 89.451 200 200 0 110.532-89.451 200-200 200-110.532 0-200-89.451-200-200 0-110.532 89.451-200 200-200m140.204 130.267l-22.536-22.718c-4.667-4.705-12.265-4.736-16.97-.068L215.346 303.697l-59.792-60.277c-4.667-4.705-12.265-4.736-16.97-.069l-22.719 22.536c-4.705 4.667-4.736 12.265-.068 16.971l90.781 91.516c4.667 4.705 12.265 4.736 16.97.068l172.589-171.204c4.704-4.668 4.734-12.266.067-16.971z">
                  </path>
                </svg>
              <% end %>
            </div>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end
