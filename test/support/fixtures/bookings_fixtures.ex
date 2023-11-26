defmodule Ukio.BookingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ukio.Bookings` context.
  """
  alias Ukio.ApartmentsFixtures
  
  @doc """
  Generate a booking.
  """
  def booking_fixture(attrs \\ %{}) do
    apartment = ApartmentsFixtures.apartment_fixture()

    {:ok, booking} =
      attrs
      |> Enum.into(%{
        apartment_id: apartment.id,
        check_in: ~D[2023-03-26],
        check_out: ~D[2023-03-26],
        deposit: 100_000,
        monthly_rent: apartment.monthly_price,
        utilities: 20000,
		market: "normal"
      })
      |> Ukio.Bookings.create_booking()

    booking
  end
end