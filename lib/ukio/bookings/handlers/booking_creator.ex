defmodule Ukio.Bookings.Handlers.BookingCreator do
  alias Ukio.Apartments
  alias Ukio.Bookings  
  
  alias Ukio.Bookings.Booking
  
  def create(
        %{"check_in" => check_in, "check_out" => check_out, "apartment_id" => apartment_id, "market" => market}
      ) do
    with {:ok, apartment} <- Apartments.get_apartment!(apartment_id),
         {:ok, _} <- check_availability(apartment_id, check_in, check_out),
         {:ok, booking} <- generate_booking_data(apartment, check_in, check_out, market) do
	  Bookings.create_booking(booking)
    else
      {:error, :unavailable} -> {:error, :unavailable}
      _ -> {:error, :invalid_request}
    end
  end
	
  defp check_availability(apartment_id, check_in, check_out) do
	case Bookings.list_bookings_for_apartment(apartment_id) do
	  {:ok, existing_bookings} ->
		if is_available?(existing_bookings, check_in, check_out) do
		  {:ok, :available}
		else
          {:error, :unavailable}
		end
      _ ->
        {:error, :unknown}
    end
  end
  
  defp is_available?(existing_bookings, check_in, check_out) do
	Enum.all?(existing_bookings, fn booking ->
      not (check_out <= booking.check_in or check_in >= booking.check_out)
    end)
  end

  defp generate_booking_data(apartment, check_in, check_out, market) do
    %{
      apartment_id: apartment.id,
      check_in: check_in,
      check_out: check_out,
      monthly_rent: apartment.monthly_price,
      deposit: Booking.calculate_deposit(apartment.monthly_price, market),
      utilities: Booking.calculate_utilities(apartment.square_meters, market),
      market: market
    }
  end
end
