defmodule UkioWeb.ErrorJSONTest do
  use UkioWeb.ConnCase, async: true

  test "renders 422" do
    assert UkioWeb.ErrorJSON.render("422.json", %{}) == %{errors: %{detail: "Unprocessable Entity"}}
  end
  
  test "renders 404" do
    assert UkioWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert UkioWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
