defmodule UkioWeb.BookingController do
  use UkioWeb, :controller

  alias Ukio.Bookings
  alias Ukio.Bookings.Booking
  alias Ukio.Bookings.Handlers.BookingCreator

  action_fallback UkioWeb.FallbackController

  def create(conn, %{"booking" => booking_params}) do
	 with {:ok, %Booking{} = booking} <- BookingCreator.create(Map.put(booking_params, "market", "normal")) do
      conn
      |> put_status(:created)
      |> render(:show, booking: booking)
    else
      {:error, :unavailable} ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, %{error: "Apartment is unavailable for the selected dates"})
      {:error, :invalid_request} ->
        conn
        |> put_status(:bad_request)
        |> render(:error, %{error: "Invalid request"})
    end
  end

  def show(conn, %{"id" => id}) do
    booking = Bookings.get_booking!(id)
    render(conn, :show, booking: booking)
  end
end
