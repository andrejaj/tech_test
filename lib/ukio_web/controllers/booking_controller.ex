defmodule UkioWeb.BookingController do
  use UkioWeb, :controller

  alias Ukio.Bookings
  alias Ukio.Bookings.Booking
  alias Ukio.Bookings.Handlers.BookingCreator

  action_fallback UkioWeb.FallbackController

  def create(conn, %{"booking" => booking_params}) do
	 with {:ok, %Booking{} = booking} <- BookingCreator.create(booking_params) do
	   conn
	   |> put_status(:created)
       |> render(:show, booking: booking)
     else
      {:error, :unavailable} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(UkioWeb.BookingJSON)
        |> render("error.json", %{error: "Apartment is unavailable for the selected dates"})
      {:error, :invalid_request} ->
        conn
        |> put_status(:unprocessable_entity) #(:bad_request)
        |> put_view(UkioWeb.BookingJSON)
        |> render("error.json", %{error: "Invalid request"})
     end
  end

  def index(conn, _params) do
    bookings = Bookings.list_bookings() # Adjust this line based on your actual logic
    render(conn, "index.json", bookings: bookings)
  end
end
