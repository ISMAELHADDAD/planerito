defmodule Planerito.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Planerito.Repo

  alias Planerito.Events.Event

  def list_events do
    Repo.all(Event)
  end

  def list_day_events(date) do
    Repo.all(
      from(e in Event,
        where: ^date == e.date,
        order_by: [e.sort_order, e.updated_at]
      )
    )
  end

  def list_week_events(date) do
    beginning_of_week = Date.beginning_of_week(date)
    end_of_week = Date.end_of_week(date)

    Repo.all(
      from(e in Event,
        where: ^beginning_of_week <= e.date and e.date <= ^end_of_week,
        order_by: [e.sort_order, e.updated_at]
      )
    )
  end

  def get_event!(id), do: Repo.get!(Event, id)

  def create_event(attrs \\ %{}) do
    attrs = maybe_calculate_new_sort_order(attrs)

    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  def update_event(%Event{} = event, attrs) do
    with attrs <- maybe_calculate_new_sort_order(attrs),
         {:ok, _} <- order_events_if_date_change(attrs, event) do
      event
      |> Event.changeset(attrs)
      |> Repo.update()
    end
  end

  defp order_events_if_date_change(%{"date" => date}, %Event{} = event) do
    new_date = Date.from_iso8601!(date)

    case new_date == event.date do
      true -> {:ok, nil}
      false -> date |> list_day_events() |> order_events()
    end
  end

  defp order_events_if_date_change(_attrs, _event), do: {:ok, nil}

  defp order_events(events) do
    events
    |> Enum.with_index()
    |> Enum.reduce(Multi.new(), fn {event, index}, multi ->
      Multi.update(
        multi,
        {:event_update_sort_order, event.id},
        Event.changeset(event, %{"sort_order" => index})
      )
    end)
    |> Repo.transaction()
  end

  defp maybe_calculate_new_sort_order(%{"date" => date} = attrs) do
    events = list_day_events(date)
    Map.put(attrs, "sort_order", Enum.count(events))
  end

  defp maybe_calculate_new_sort_order(attrs), do: attrs

  def external_order_events(new_event_order_list) do
    event_ids = Enum.map(new_event_order_list, & &1["id"])

    Repo.all(from(e in Event, where: e.id in ^event_ids))
    |> Enum.reduce(Multi.new(), fn event, multi ->
      %{"date" => date, "sort_order" => sort_order} =
        new_event_order_list
        |> Enum.find(&(&1["id"] == "#{event.id}"))

      Multi.update(
        multi,
        {:event_update_sort_order, event.id},
        Event.changeset(event, %{"date" => date, "sort_order" => sort_order})
      )
    end)
    |> Repo.transaction()
  end

  def delete_event(%Event{} = event) do
    event.date
    |> list_day_events()
    |> Enum.filter(&(&1.id != event.id))
    |> order_events()

    Repo.delete(event)
  end

  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end
end
