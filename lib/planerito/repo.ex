defmodule Planerito.Repo do
  use Ecto.Repo,
    otp_app: :planerito,
    adapter: Ecto.Adapters.SQLite3
end
