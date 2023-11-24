defmodule UkioWeb.BookingJSON do
  alias Ukio.Bookings.Booking

  @doc """
  Renders a list of bookings.
  """
  def index(%{bookings: bookings}) do
    %{data: for(booking <- bookings, do: data(booking))}
  end

  @doc """
  Renders a single booking.
  """
  def show(%{booking: booking}) do
    %{data: data(booking)}
  end

  defp data(%Booking{} = booking) do
    %{
      id: booking.id,
      check_in: booking.check_in,
      check_out: booking.check_out,
      apartment_id: booking.apartment_id,
      monthly_rent: booking.monthly_rent,
      deposit: booking.deposit,
      utilities: booking.utilities
    }
  end
end
