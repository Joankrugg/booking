require "test_helper"
class ModernBoxV3Test < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @owner = User.create!(email: "v3-owner@example.test", password: "secret-password", active: true)
    @owner.membership.update!(starts_on: Date.current - 1, ends_on: Date.current + 30)
    @group = @owner.owned_groups.create!(name: "V3 band", city: "Bordeaux", contact_email: @owner.email, published: true)
    @day = Date.current + 7
  end
  def availability(date: @day, area: "Bordeaux", radius: 50, status: "available")
    @group.concert_availabilities.create!(date: date, area_name: area, travel_radius_km: radius, status: status, confirmed_by: @owner, confirmed_at: Time.current)
  end
  def concert(city, title)
    @group.concerts.create!(title: title, starts_at: @day.in_time_zone.change(hour: 20), city: city, venue_name: "Salle", published: true)
  end
  def calendar_update(extra = {})
    post member_group_availability_calendar_path(@group), params: { month: @day.beginning_of_month, area_name: "Bordeaux", travel_radius_km: 30, paint: "available", single_date: @day.iso8601 }.merge(extra)
  end
  test "availability search starts with upcoming results without a required date" do
    availability
    get availabilities_path
    assert_response :success
    assert_includes response.body, "V3 band"
    assert_includes response.body, "Prochaines dates"
    assert_select 'input[name=date][required]', count: 0
    get availabilities_path(date: @day + 1)
    assert_not_includes response.body, "V3 band"
  end
  test "moving the calendar month does not apply a date filter" do
    availability(date: Date.current + 80)
    get availabilities_path(month: Date.current.next_month)
    assert_includes response.body, "V3 band"
    assert_select 'input[name=date][value]', count: 0
  end
  test "concert proximity includes Floirac and Merignac but excludes Paris" do
    concert("Floirac", "Floirac live")
    concert("Mérignac", "Merignac live")
    concert("Paris", "Paris live")
    get concerts_path(place: "Bordeaux", radius: 15)
    assert_response :success
    assert_includes response.body, "Floirac live"
    assert_includes response.body, "Merignac live"
    assert_not_includes response.body, "Paris live"
    get concerts_path(place: "Bordeaux", radius: 0)
    assert_not_includes response.body, "Floirac live"
  end
  test "touring areas cover the searched place and unknown geography never claims proximity" do
    near = availability(area: "Floirac", radius: 10)
    far = availability(area: "Paris", radius: 10)
    unknown = availability(area: "Unknown area", radius: 1000)
    get availabilities_path(area: "Bordeaux", radius: 0)
    assert_response :success
    assert_includes response.body, "Floirac"
    assert_not_includes response.body, "Unknown area"
    assert_not_includes response.body, "Paris"
    far.update!(travel_radius_km: 600)
    get availabilities_path(area: "Bordeaux", radius: 0)
    assert_includes response.body, "Paris"
  end
  test "unknown search location gives an explicit error rather than unrelated results" do
    availability
    get availabilities_path(area: "Does not exist")
    assert_response :success
    assert_includes response.body, "Lieu non reconnu"
    assert_not_includes response.body, "V3 band"
  end
  test "calendar click can mark available unavailable and clear without inventing other dates" do
    sign_in @owner, scope: :user
    get member_group_availability_calendar_path(@group, month: @day)
    assert_response :success
    assert_select 'button.state-unknown'
    calendar_update
    assert_redirected_to member_group_availability_calendar_path(@group, month: @day.beginning_of_month, area_name: "Bordeaux", travel_radius_km: 30)
    record = @group.concert_availabilities.sole
    assert_equal "available", record.status
    assert_equal 30, record.travel_radius_km
    assert_equal @owner.id, record.confirmed_by_id
    calendar_update(paint: "unavailable")
    assert_equal "unavailable", record.reload.status
    assert_equal 1, @group.concert_availabilities.count
    get availabilities_path
    assert_not_includes response.body, "V3 band"
    calendar_update(paint: "clear")
    assert_equal 0, @group.concert_availabilities.count
  end
  test "JSON clicks return persisted state and validation failure does not paint a date" do
    sign_in @owner, scope: :user
    post member_group_availability_calendar_path(@group), params: { single_date: @day, area_name: "Bordeaux", travel_radius_km: 20, paint: "available" }, as: :json
    assert_response :success
    assert JSON.parse(response.body)["ok"]
    post member_group_availability_calendar_path(@group), params: { single_date: @day + 1, area_name: "Bordeaux", travel_radius_km: -1, paint: "available" }, as: :json
    assert_response :unprocessable_entity
    assert_equal 1, @group.concert_availabilities.count
  end
  test "period selects only the selected weekdays and repeated submits update rather than duplicate" do
    sign_in @owner, scope: :user
    first = Date.current + 7
    last = first + 20
    expected = (first..last).select(&:friday?)
    payload = { mode: "period", single_date: nil, from: first, to: last, weekdays: ["5"] }
    2.times { calendar_update(payload) }
    assert_response :redirect
    assert_equal expected, @group.concert_availabilities.order(:date).pluck(:date)
  end
  test "invalid large reversed past or empty periods never write partial dates" do
    sign_in @owner, scope: :user
    [ { from: @day, to: @day + 400, weekdays: ["5"] }, { from: @day, to: @day - 1, weekdays: ["5"] }, { from: Date.current - 1, to: @day, weekdays: %w[0 1 2 3 4 5 6] }, { from: @day, to: @day + 3, weekdays: [] } ].each do |range|
      calendar_update(range.merge(mode: "period", single_date: nil))
      assert_response :unprocessable_entity
      assert_equal 0, @group.concert_availabilities.count
    end
  end
  test "calendar scopes the group independently of membership" do
    stranger = User.create!(email: "v3-stranger@example.test", password: "secret-password", active: true)
    stranger.membership.update!(starts_on: Date.current, ends_on: Date.current + 30)
    sign_in stranger, scope: :user
    calendar_update
    assert_response :not_found
    assert_equal 0, @group.concert_availabilities.count
    sign_in @owner, scope: :user
    @owner.membership.update!(status: "revoked")
    calendar_update
    assert_response :success
    assert_equal 1, @group.concert_availabilities.count
  end
  test "one account can be both organizer and artist with both dashboard paths" do
    post user_registration_path, params: { user: { email: "both@example.test", password: "secret-password", password_confirmation: "secret-password", usage_choices_submitted: "1", uses_groups: "1", uses_organizing: "1", uses_concerts: "1", organizer_type: "venue_manager", admin: true, active: true } }
    assert_redirected_to member_root_path
    user = User.find_by!(email: "both@example.test")
    assert user.uses_groups?
    assert user.uses_organizing?
    assert_not user.admin?
    assert user.membership.active?
    assert_not user.skill_access?
    follow_redirect!
    assert_includes response.body, "Programmer un concert"
    assert_includes response.body, "Ajouter un groupe"
    assert_includes response.body, "Explorer les concerts"
  end
  test "empty multi-use selection is rejected" do
    post user_registration_path, params: { user: { email: "empty-use@example.test", password: "secret-password", password_confirmation: "secret-password", usage_choices_submitted: "1", uses_groups: "0", uses_organizing: "0", uses_concerts: "0" } }
    assert_response :unprocessable_entity
    assert_not User.exists?(email: "empty-use@example.test")
  end
  test "calendar painting preserves existing notes and hours unless explicitly replaced" do
    record = availability
    record.update!(public_note: "Keep me", starts_at_time: "18:00", ends_at_time: "22:00")
    sign_in @owner, scope: :user
    calendar_update(public_note: "", starts_at_time: "", ends_at_time: "", replace_details: "0", paint: "on_request")
    assert_equal "Keep me", record.reload.public_note
    assert_equal "18:00", record.starts_at_time.strftime("%H:%M")
    calendar_update(public_note: "", starts_at_time: "", ends_at_time: "", replace_details: "1")
    assert_equal "", record.reload.public_note
    assert_nil record.starts_at_time
    assert_nil record.ends_at_time
  end
  test "pagination does not remove future dates or let suspended owners leak" do
    52.times { |i| availability(date: Date.current + i + 1) }
    get availabilities_path
    assert_select 'article.card', count: 50
    assert_includes response.body, "Résultats suivants"
    get availabilities_path(page: 2)
    assert_select 'article.card', count: 2
    @owner.update!(active: false)
    get availabilities_path(page: 2)
    assert_select 'article.card', count: 0
  end

end
