defmodule Ukio.Repo.Migrations.AddMarketToBookings do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      modify :updated_at, :timestamp, null: false
      add :market, :string
    end
  end
end