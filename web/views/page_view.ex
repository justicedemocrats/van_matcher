defmodule VanMatcher.PageView do
  use VanMatcher.Web, :view
  import ShortMaps

  def csrf_token do
    Plug.CSRFProtection.get_csrf_token()
  end

  def fields do
    [
      {"First Name", "firstName", false},
      {"Last Name", "lastName", false},
      {"Phone Number", "phoneNumber", true},
      {"Email Address", "emailAddress", true},
      {"Birth Date", "dateOfBirth", true},
      {"Zip", "zipOrPostalCode", true}
    ]
    |> Enum.map(fn {label, key, optional} -> ~m(label key optional)a end)
  end
end
