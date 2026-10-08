require "test_helper"
require "minitest/mock"
class ModernBoxV3CoreTest < ActiveSupport::TestCase
  setup do
    @owner = User.create!(email: "v3-core@example.test", password: "secret-password", active: true)
    @group = @owner.owned_groups.create!(name: "Core", contact_email: @owner.email)
  end
  test "invalid time ranges are atomic and do not overwrite existing days" do
    day = Date.current + 10
    record = @group.concert_availabilities.create!(date: day, area_name: "Bordeaux", confirmed_by: @owner, confirmed_at: Time.current)
    assert_raises(AvailabilityBatch::Invalid) do
      AvailabilityBatch.apply(group: @group, user: @owner, dates: [day, day + 1], attributes: { area_name: "Bordeaux", travel_radius_km: 50, status: "unavailable", starts_at_time: "23:00", ends_at_time: "20:00" })
    end
    assert_equal "available", record.reload.status
    assert_equal 1, @group.concert_availabilities.count
  end
  test "valid partial-day times persist and a missing endpoint is rejected" do
    record = @group.concert_availabilities.new(date: Date.current + 1, area_name: "Bordeaux", confirmed_by: @owner, confirmed_at: Time.current, starts_at_time: "18:00", ends_at_time: "22:00")
    assert record.save
    assert_equal "18:00", record.reload.starts_at_time.strftime("%H:%M")
    record.ends_at_time = nil
    assert_not record.valid?
  end
  test "successful locations are cached and need no provider call" do
    result = PlaceResolver.resolve("Bordeaux")
    assert result.located?
    assert_equal 44.8378, result.latitude
    assert_nil GeocodingGate.find(1).requested_at
  end
  test "uncached lookup resolves once and repeated queries reuse the cache" do
    Geocoder::Lookup::Test.add_stub("Nantes, France", [{ "coordinates" => [47.2184, -1.5536] }])
    first = PlaceResolver.resolve("Nantes")
    assert first.located?
    assert_equal first.id, PlaceResolver.resolve("nantes").id
    assert_nil PlaceResolver.resolve("Another place")
    assert GeocodingGate.find(1).requested_at
  end
  test "failed lookups are cached and do not fabricate coordinates" do
    result = PlaceResolver.resolve("Unknown address")
    assert_not result.located?
    GeocodingGate.find(1).update!(requested_at: 10.seconds.ago)
    assert_equal result.id, PlaceResolver.resolve("Unknown address").id
    assert_operator GeocodingGate.find(1).requested_at, :<, 1.second.ago
  end
  test "changing a location clears obsolete coordinates when the new place fails" do
    record = @group.concert_availabilities.create!(date: Date.current + 1, area_name: "Bordeaux", confirmed_by: @owner, confirmed_at: Time.current)
    assert_equal 44.8378, record.latitude
    record.update!(area_name: "Missing place")
    assert_nil record.reload.latitude
    assert_nil record.longitude
  end
  test "existing organizers can add the artist use without another account" do
    user = User.create!(email: "multi-core@example.test", password: "secret-password", active: true, profile_type: "organizer", organizer_type: "promoter")
    assert user.uses_organizing?
    user.update!(uses_groups: true, usage_choices_submitted: "1")
    assert user.uses_groups?
    assert user.uses_organizing?
  end
  test "production geocoder SQL matches exact circle and variable touring radius" do
    connection = ActiveRecord::Base.connection
    skip "SQLite helper only; PostgreSQL integration tests cover the real SQL branch" unless connection.adapter_name == "SQLite"
    raw = connection.raw_connection
    raw.create_function("PI", 0) { |function| function.result = Math::PI }
    { "SIN" => :sin, "COS" => :cos, "ASIN" => :asin, "SQRT" => :sqrt }.each do |name, method|
      raw.create_function(name, 1) { |function, number| function.result = number.nil? ? nil : Math.send(method, number) }
    end
    raw.create_function("POWER", 2) { |function, base, exponent| function.result = base.nil? ? nil : base ** exponent }
    day = Date.current + 10
    near = @group.concert_availabilities.create!(date: day, area_name: "Floirac", travel_radius_km: 10, confirmed_by: @owner, confirmed_at: Time.current)
    far = @group.concert_availabilities.create!(date: day, area_name: "Paris", travel_radius_km: 10, confirmed_by: @owner, confirmed_at: Time.current)
    place = PlaceResolver.resolve("Bordeaux")
    relation = connection.stub(:adapter_name, "PostgreSQL") { GeographicSearch.filter(ConcertAvailability.all, place, 0, touring: true) }
    assert_equal [near.id], relation.pluck(:id)
    far.update!(travel_radius_km: 600)
    assert_equal [near.id, far.id].sort, relation.pluck(:id).sort
  end

end
