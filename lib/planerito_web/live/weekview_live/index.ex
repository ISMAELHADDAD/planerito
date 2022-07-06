defmodule PlaneritoWeb.WeekViewLive.Index do
  use PlaneritoWeb, :live_view

  alias Planerito.Events
  alias PlaneritoWeb.Components.TodoList

  def mount(_params, _session, socket) do
    selected_week = today() |> Date.beginning_of_week()
    events = Events.list_week_events(selected_week)

    {:ok,
     socket
     |> assign(selected_week: selected_week)
     |> assign(events: events)}
  end

  def handle_event("sort", %{"list" => list}, socket) do
    list
    |> Enum.each(fn %{"id" => id, "list_id" => list_id, "sort_order" => sort_order} ->
      Events.get_event!(id)
      |> Events.update_event(%{date: list_id, sort_order: sort_order})
    end)

    {:noreply, socket}
  end

  def handle_event("add_new_event", %{"event" => event_attrs}, socket) do
    with _event <- Events.create_event(event_attrs) do
      events = Events.list_week_events(socket.assigns.selected_week)
      {:noreply, socket |> assign(events: events)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("toggle_completed", %{"id" => event_id}, socket) do
    with event <- Events.get_event!(event_id),
         _event <- Events.update_event(event, %{is_completed: !event.is_completed}) do
      events = Events.list_week_events(socket.assigns.selected_week)
      {:noreply, socket |> assign(events: events)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("nav_week", %{"direction" => direction}, socket) do
    selected_week = jump_week(socket.assigns.selected_week, direction)
    events = Events.list_week_events(selected_week)

    {:noreply,
     socket
     |> assign(selected_week: selected_week)
     |> assign(events: events)}
  end

  defp today, do: Date.utc_today()

  defp day_of_week(selected_week, num_day), do: Date.add(selected_week, num_day)

  defp jump_week(date, "prev"), do: Date.add(date, -7)
  defp jump_week(date, "next"), do: Date.add(date, 7)
  defp jump_week(_date, "today"), do: today() |> Date.beginning_of_week()

  defp filter_events_by_date(events, date),
    do: Enum.filter(events, &(Date.compare(&1.date, date) == :eq))
end
