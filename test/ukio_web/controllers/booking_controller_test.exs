defmodule UkioWeb.BookingControllerTest do
  use UkioWeb.ConnCase, async: true
  
  alias Ukio.Apartments
  alias Ukio.Bookings
  
  import Ukio.ApartmentsFixtures
  
  @create_attrs %{
    apartment_id: 1,
    check_in: ~D[2023-03-26],
    check_out: ~D[2023-03-26],
	market: "normal"
  }
  
  @invalid_attrs %{
    apartment_id: 1,
    check_in: nil,
    check_out: nil,
    deposit: nil,
    monthly_rent: nil,
    utilities: nil,
	market: nil
  }
  
  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"), apartment: apartment_fixture()}
  end

  describe "create booking" do
  
    test "renders booking when data is valid", %{conn: conn, apartment: apartment} do
      b = Map.merge(@create_attrs, %{apartment_id: apartment.id}, fn _, existing, _ -> existing end)
	  conn = post(conn, ~p"/api/bookings", booking: b)
	  
      assert %{"id" => id} = json_response(conn, 201)["data"]
	  
      conn = get(conn, ~p"/api/bookings/#{id}")
	  
      assert %{
               "id" => ^id,
               "check_in" => "2023-03-26",
               "check_out" => "2023-03-26",
               "deposit" => 100_000,
               "monthly_rent" => 250_000,
               "utilities" => 20000
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, apartment: apartment} do
      b = Map.merge(@invalid_attrs, %{apartment_id: apartment.id})
      conn = post(conn, ~p"/api/bookings", %{"booking" => b})
	  assert json_response(conn, 422) == %{"error" => "Invalid request"}
    end
	
	test "returns 401 if apartment is unavailable", %{conn: conn, apartment: apartment} do
      # Book the apartment for a specific date range
      booking_attrs = %{
        apartment_id: apartment.id,
        check_in: ~D[2023-03-26],
        check_out: ~D[2023-03-28],
        deposit: 100_000,
        monthly_rent: 250_000,
        utilities: 20000
      }

      {:ok, _booking} = Bookings.create_booking(booking_attrs)

      # Try to book the same apartment for overlapping dates
      overlapping_booking_attrs = %{
        apartment_id: apartment.id,
        check_in: ~D[2023-03-27],
        check_out: ~D[2023-03-29],
        deposit: 100_000,
        monthly_rent: 250_000,
        utilities: 20000
      }

      conn = post(conn, ~p"/api/bookings", booking: overlapping_booking_attrs)
	  assert json_response(conn, 401) == %{"error" => "Unauthorized"}
    end
	
	test "books apartment in 'Mars' market with correct deposit and utilities", %{conn: conn, apartment: apartment} do
      # Set the market to "Mars" for the apartment
      updated_apartment_attrs = Map.put(apartment, "market", "Mars")
      {:ok, _updated_apartment} = Apartments.update_apartment(apartment, updated_apartment_attrs)

      # Book the apartment in "Mars" market
      booking_attrs = %{
        apartment_id: apartment.id,
        check_in: ~D[2023-03-26],
        check_out: ~D[2023-04-26],
      }

      conn = post(conn, ~p"/api/bookings", booking: booking_attrs)
      assert conn.status == 201

      # Retrieve the created booking
      [booking] = json_response(conn, 201)["data"]

      # Verify the market-specific conditions
      assert booking["deposit"] == booking["monthly_rent"]
      # Assuming utilities are linked to square meters, adjust the assertion based on your implementation
      assert booking["utilities"] == apartment.square_meters * 1000
    end
  end
end
