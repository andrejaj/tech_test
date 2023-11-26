defmodule UkioWeb.ApartmentController do
  use UkioWeb, :controller

  alias Ukio.Apartments.Apartment
  alias Ukio.Apartments

  action_fallback UkioWeb.FallbackController

  def index(conn, _params) do
    apartments = Apartments.list_apartments()
    render(conn, :index, apartments: apartments)
  end
  
  def create(conn, %{"apartment" => apartment_params}) do
      with {:ok, %Apartment{} = apartment} <- Apartments.create_apartment(apartment_params) do
        conn
        |> put_status(:created)
		|> render(:show, apartment: apartment)
	  else
      {:error, _} ->
        conn
        |> put_status(:bad_request)
		|> render(:error, %{error: "Invalid request"})
    end
  end
end