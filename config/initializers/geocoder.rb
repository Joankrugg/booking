Geocoder.configure(
  timeout: 5,
  lookup: Rails.env.test? ? :test : ENV.fetch("GEOCODER_LOOKUP", "nominatim").to_sym,
  api_key: ENV["GEOCODER_API_KEY"],
  use_https: true,
  units: :km,
  http_headers: { "User-Agent" => "ModernBox/3.0 (modernboxrecords@gmail.com)" },
  always_raise: []
)
