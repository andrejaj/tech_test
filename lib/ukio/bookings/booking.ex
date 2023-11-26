defmodule Ukio.Bookings.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ukio.Apartments.Apartment

  schema "bookings" do
    belongs_to(:apartment, Apartment)

    field :check_in, :date
    field :check_out, :date
    field :deposit, :integer
    field :monthly_rent, :integer
    field :utilities, :integer
	field :market, :string, default: "normal"
	
    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [
		:check_in, 
		:check_out, 
		:apartment_id, 
		:monthly_rent, 
		:deposit,
	    :utilities,
		:market
	])
    |> validate_required([
      :check_in,
      :check_out,
      :apartment_id,
      :monthly_rent,
      :deposit,
	  :utilities,
	  :market
    ])
  end
  
  def calculate_deposit(monthly_rent, "mars"), do: monthly_rent
  def calculate_deposit(monthly_rent, _), do: div(monthly_rent, 2)

  def calculate_utilities(square_meters, "mars") do
	utilities_rate = 476.2 # utilities_rate= utilities / square_meters 
	result = square_meters * utilities_rate
	:erlang.floor(result)
  end
  def calculate_utilities(_square_meters, _utilities_rate, _), do: 20_000
end
