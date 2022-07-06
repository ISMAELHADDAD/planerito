defmodule Planerito.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :date, :date
    field :is_completed, :boolean, default: false
    field :sort_order, :integer
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:date, :title, :is_completed, :sort_order])
    |> validate_required([:date, :title, :sort_order])
  end
end
