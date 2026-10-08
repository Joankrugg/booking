require "test_helper"
class ModernBoxV4Test < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = User.create!(email: "v4@example.test", password: "secret-password", active: true)
    @group = @user.owned_groups.create!(name: "V4", city: "Bordeaux", contact_email: @user.email, published: true)
    sign_in @user, scope: :user
  end
  test "automatic membership never grants paid access and cannot be self assigned" do
    assert @user.membership.active?
    assert_not @user.skill_access?
    patch user_registration_path, params: { user: { current_password: "secret-password", skills_access_until: "2099-01-01" } }
    assert_nil @user.reload.skills_access_until
  end
  test "undo restores complete details and cannot overwrite subsequent changes" do
    record = @group.concert_availabilities.create!(date: Date.current, area_name: "Bordeaux", travel_radius_km: 50, status: "on_request", public_note: "Original", confirmed_by: @user, confirmed_at: Time.current)
    post member_group_availability_calendar_path(@group), params: { single_date: Date.current.iso8601, area_name: "Bordeaux", travel_radius_km: 80, paint: "available" }, as: :json
    assert_response :success
    token = response.parsed_body.fetch("undo_token")
    post member_group_availability_calendar_path(@group), params: { undo_token: token }, as: :json
    assert_response :success
    assert_equal "on_request", record.reload.status
    assert_equal 50, record.travel_radius_km
    assert_equal "Original", record.public_note
    post member_group_availability_calendar_path(@group), params: { undo_token: token }, as: :json
    assert_response :unprocessable_entity
  end
  test "calendar initially displays disabled editing and two steps" do
    get member_group_availability_calendar_path(@group)
    assert_response :success
    assert_includes response.body, "Préparer les disponibilités"
    assert_includes response.body, "Appliquer aux dates"
    assert_select ".availability-editor button:not([disabled])", count: 0
  end
end
