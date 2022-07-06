defmodule PlaneritoWeb.Components.TodoList do
  use PlaneritoWeb, :component

  alias Phoenix.LiveView.JS

  def list_day(assigns) do
    assigns =
      assigns
      |> assign_new(:date, fn -> Date.utc_today() end)
      |> assign_new(:items, fn -> [] end)

    ~H"""
    <div class="relative px-3 pt-[42px] mt-8 lg:mt-0">
      <div class="flex flex-col h-full">
        <div class={
          Enum.join(
            [
              "absolute top-0 left-3 right-3 text-xl border-b-2 pb-3 flex justify-between",
              if(Date.compare(Date.utc_today(), @date) == :eq, do: "border-blue-400 text-blue-400", else: "border-black text-black")
            ],
            " "
          )
        }>
          <span class="font-bold"><%= Calendar.strftime(@date, "%d.%m") %></span>
          <span class="opacity-20"><%= Calendar.strftime(@date, "%a") %></span>
        </div>

        <.list date={@date} items={@items} />
      </div>
    </div>
    """
  end

  def group(assigns) do
    ~H"""
    <div class="grid grid-rows-2 gap-y-[42px] lg:px-3">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def list(assigns) do
    assigns =
      assigns
      |> assign_new(:date, fn -> "#list_#{Ecto.UUID.generate()}" end)
      |> assign_new(:items, fn -> [] end)
      |> assign_new(:changeset, fn -> Planerito.Events.change_event(%Planerito.Events.Event{}) end)

    ~H"""
    <div class="flex grow shrink basis-full cell-background">
      <div class="w-full">
        <ul id={@date} phx-hook="InitSortable" data-list-id={@date}>
          <%= for item <- @items do %>
            <.cell data-sortable-id={item.id} item={item} />
          <% end %>
        </ul>
        <!-- Input -->
        <div id={"input-wrapper-#{@date}"} class="relative border-b border-transparent hover:border-blue-400">
          <.form let={f} for={@changeset} phx-submit="add_new_event">
            <%= text_input(f, :title, id: "input-#{@date}", class: "relative text-sm w-full h-[41px] z-10 bg-transparent focus:outline-none", autocomplete: "none", phx_focus: on_input_focus(@date), phx_blur: on_input_blur(@date)) %>
            <%= hidden_input(f, :date, id: "hidden-date-#{@date}", value: @date) %>
            <%= hidden_input(f, :sort_order, id: "hidden-sort-order-#{@date}", value: Enum.count(@items)) %>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  defp on_input_focus(date) do
    JS.add_class(
      "before:content-[\'\'] before:absolute before:-inset-y-0.5 before:-inset-x-2 before:rounded before:shadow-xl before:bg-white",
      to: "#input-wrapper-#{date}"
    )
  end

  defp on_input_blur(date) do
    JS.remove_class(
      "before:content-[\'\'] before:absolute before:-inset-y-0.5 before:-inset-x-2 before:rounded before:shadow-xl before:bg-white",
      to: "#input-wrapper-#{date}"
    )
  end

  def cell(assigns) do
    assigns =
      assigns
      |> assign_new(:item, fn -> nil end)
      |> assign_new(:extra_assigns, fn ->
        assigns_to_attributes(assigns, ~w(
          class
          item
        )a)
      end)

    ~H"""
    <li {@extra_assigns} class="show-check-on-hover relative list-none cursor-pointer box-border h-[42px] pr-6 border-b border-transparent hover:border-blue-400">
      <div class="cursor-grab touch-manipulation w-full py-[10px]">
        <span class={
          Enum.join(
            [
              "select-none max-w-full w-full rounded-xl py-[6px] overflow-hidden text-sm text-ellipsis whitespace-nowrap box-border",
              if(@item.is_completed, do: "line-through opacity-30", else: "")
            ],
            " "
          )
        }>
          <%= @item.title %>
        </span>
      </div>
      <div class="check-completed absolute h-full flex flex-col justify-center top-0 right-0 lg:invisible hover:visible" phx-click="toggle_completed" phx-value-id={@item.id}>
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
    </li>
    """
  end
end
