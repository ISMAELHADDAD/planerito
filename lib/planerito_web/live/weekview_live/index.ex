defmodule PlaneritoWeb.WeekViewLive.Index do
  use PlaneritoWeb, :live_view

  alias Planerito.Events
  alias PlaneritoWeb.Components.TodoList
  alias PlaneritoWeb.Components.TodoForm

  def mount(_params, _session, socket) do
    selected_week = today() |> Date.beginning_of_week()
    events = Events.list_week_events(selected_week)

    {:ok,
     socket
     |> assign(selected_week: selected_week)
     |> assign(events: events)
     |> assign(selected_event: nil)}
  end

  def handle_event("sort", %{"list" => events}, socket) do
    Events.external_order_events(events)
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

  def handle_event("delete_event", %{"id" => event_id}, socket) do
    with event <- Events.get_event!(event_id),
         _event <- Events.delete_event(event),
         events <- Events.list_week_events(socket.assigns.selected_week) do
      {:noreply, socket |> assign(events: events) |> assign(selected_event: nil)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("edit_event", %{"event" => event_attrs}, socket) do
    with {:ok, event} <- Events.update_event(socket.assigns.selected_event, event_attrs),
         events <- Events.list_week_events(socket.assigns.selected_week) do
      {:noreply, socket |> assign(events: events) |> assign(selected_event: event)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("toggle_completed", %{"id" => event_id}, socket) do
    with event <- Events.get_event!(event_id),
         {:ok, event} <- Events.update_event(event, %{is_completed: !event.is_completed}) do
      events = Events.list_week_events(socket.assigns.selected_week)

      {:noreply,
       socket
       |> assign(events: events)
       |> assign(selected_event: if(is_nil(socket.assigns.selected_event), do: nil, else: event))}
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

  def handle_event("select_event", %{"id" => event_id}, socket) do
    event = Events.get_event!(event_id)
    events = Events.list_week_events(socket.assigns.selected_week)

    {:noreply,
     socket
     |> assign(events: events)
     |> assign(selected_event: event)}
  end

  def handle_event("deselect_event", _params, socket) do
    events = Events.list_week_events(socket.assigns.selected_week)

    {:noreply,
     socket
     |> assign(events: events)
     |> assign(selected_event: nil)}
  end

  defp today, do: Date.utc_today()

  defp day_of_week(selected_week, num_day), do: Date.add(selected_week, num_day)

  defp jump_week(date, "prev"), do: Date.add(date, -7)
  defp jump_week(date, "next"), do: Date.add(date, 7)
  defp jump_week(_date, "today"), do: today() |> Date.beginning_of_week()

  defp filter_events_by_date(events, date),
    do: Enum.filter(events, &(Date.compare(&1.date, date) == :eq))
end
