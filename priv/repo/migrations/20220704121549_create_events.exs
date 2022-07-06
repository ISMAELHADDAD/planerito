defmodule Planerito.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :date, :date
      add :title, :string
      add :is_completed, :boolean, default: false, null: false
      add :sort_order, :integer

      timestamps()
    end
  end
end
