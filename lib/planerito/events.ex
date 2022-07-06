defmodule Planerito.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Planerito.Repo

  alias Planerito.Events.Event

  def list_events do
    Repo.all(Event)
  end

  def list_week_events(date) do
    beginning_of_week = Date.beginning_of_week(date)
    end_of_week = Date.end_of_week(date)

    Repo.all(
      from(e in Event,
        where: ^beginning_of_week <= e.date and e.date <= ^end_of_week,
        order_by: e.sort_order
      )
    )
  end

  def get_event!(id), do: Repo.get!(Event, id)

  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end
end
