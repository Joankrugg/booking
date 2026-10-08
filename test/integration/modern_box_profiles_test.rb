require "test_helper"
class ModernBoxProfilesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @owner = User.create!(email: "artist-v2@example.test", password: "secret-password", active: true)
    @owner.membership.update!(starts_on: Date.current - 1, ends_on: Date.current + 30)
    @group = @owner.owned_groups.create!(name: "V2 group", contact_email: @owner.email, published: true)
    @concert = @group.concerts.create!(title: "V2 concert", starts_at: Date.current.to_time.change(hour: 21), venue_name: "Test salle", city: "Bordeaux", published: true)
  end
  test "organizer signs up for a free dashboard with automatic membership but without admin or paid rights" do
    post user_registration_path, params: { user: { email: "venue@example.test", password: "secret-password", password_confirmation: "secret-password", usage_choices_submitted: "1", uses_organizing: "1", organizer_type: "venue_manager", organization_name: "Test salle", admin: true } }
    assert_redirected_to member_root_path
    organizer = User.find_by!(email: "venue@example.test")
    assert_equal "organizer", organizer.profile_type
    assert organizer.membership.active?
    assert_not organizer.skill_access?
    assert_not organizer.admin?
    follow_redirect!
    assert_response :success
    assert_includes response.body, "Accès gratuit"
    get new_member_group_path
    assert_response :success
  end
  test "artist immediately accesses group management" do
    user = User.create!(email: "pending@example.test", password: "secret-password", active: true, profile_type: "artist")
    sign_in user, scope: :user
    get member_root_path
    assert_response :success
    assert_includes response.body, "Ajouter un groupe"
    assert_not_includes response.body, "Demander mon adhésion"
  end
  test "organizer must specify their activity" do
    post user_registration_path, params: { user: { email: "incomplete@example.test", password: "secret-password", password_confirmation: "secret-password", usage_choices_submitted: "1", uses_organizing: "1" } }
    assert_response :unprocessable_entity
    assert_not User.exists?(email: "incomplete@example.test")
  end
  test "audience can view concerts without login and filter by date and city" do
    get concerts_path(date: Date.current, place: "bordeaux")
    assert_response :success
    assert_includes response.body, "V2 concert"
    get concerts_path(date: Date.current, place: "Lyon")
    assert_not_includes response.body, "V2 concert"
    get concerts_path(date: Date.current + 1)
    assert_not_includes response.body, "V2 concert"
  end
  test "draft concerts stay private and cancelled concerts are labelled" do
    @concert.update!(published: false)
    get concerts_path(date: Date.current)
    assert_not_includes response.body, "V2 concert"
    @concert.update!(published: true, cancelled: true)
    get concerts_path(date: Date.current)
    assert_includes response.body, "ANNULÉ"
  end
  test "concert access is scoped to managed groups" do
    stranger = User.create!(email: "stranger@example.test", password: "secret-password", active: true)
    stranger.membership.update!(starts_on: Date.current, ends_on: Date.current + 30)
    own = stranger.owned_groups.create!(name: "Other", contact_email: stranger.email)
    sign_in stranger, scope: :user
    patch member_group_concert_path(own, @concert), params: { concert: { title: "Changed" } }
    assert_response :not_found
    assert_equal "V2 concert", @concert.reload.title
  end
  test "group managers can add concert dates without changing availability" do
    sign_in @owner, scope: :user
    get new_member_group_concert_path(@group)
    assert_response :success
    assert_difference "Concert.count", 1 do
      assert_no_difference "ConcertAvailability.count" do
        post member_group_concerts_path(@group), params: { concert: { title: "New show", starts_at: Date.current.tomorrow.to_time.change(hour: 20), city: "Paris", venue_name: "Venue", published: true } }
      end
    end
    assert_redirected_to member_group_path(@group)
    follow_redirect!
    assert_response :success
  end
  test "availability location search matches declared zones without login" do
    @group.concert_availabilities.create!(date: Date.current, area_name: "Bordeaux", confirmed_by: @owner, confirmed_at: Time.current)
    get availabilities_path(date: Date.current, area: "Bordeaux")
    assert_includes response.body, "V2 group"
    get availabilities_path(date: Date.current, area: "Paris")
    assert_not_includes response.body, "V2 group"
  end
end
