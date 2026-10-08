ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
Geocoder::Lookup::Test.set_default_stub([])
module ModernBoxLocationFixtures
  def seed_location_cache
    GeocodingGate.create_or_find_by!(id: 1)
    { "Bordeaux" => [ 44.8378, -0.5792 ], "Floirac" => [ 44.8311, -0.5265 ], "Mérignac" => [ 44.8428, -0.6461 ], "Paris" => [ 48.8566, 2.3522 ], "Lyon" => [ 45.7640, 4.8357 ] }.each do |name, coordinates|
      GeocodedPlace.create!(query_key: "france:#{name.parameterize}", label: name, latitude: coordinates[0], longitude: coordinates[1], looked_up_at: Time.current)
    end
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.


    include ModernBoxLocationFixtures
    setup :seed_location_cache
  end
end
