Geocoder.configure(
  timeout: 5,
  lookup: :nominatim,
  ip_lookup: :ipapi,
  use_https: true,
  http_headers: { "User-Agent" => "booking-app" },
  always_raise: [],
)
