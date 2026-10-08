require "test_helper"

class ModernBoxAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @owner = User.create!(email: "owner@example.test", password: "secret-password", active: true)
    @member = User.create!(email: "member@example.test", password: "secret-password", active: true)
    [@owner, @member].each { |u| u.update!(skills_access_until: Date.current + 30) }
    @group = @owner.owned_groups.create!(name: "Vector test", contact_email: @owner.email, published: true)
    @skill = Skill.create!(name: "Audience", description: "Préparer un plan", compatibility: "Markdown", published: true)
    @release = @skill.skill_releases.create!(version: "1.0", instructions: "PRIVATE_SKILL_CONTENT")
  end

  test "public catalogue renders without exposing instructions" do
    get skill_path(@skill)
    assert_response :success
    assert_not_includes response.body, "PRIVATE_SKILL_CONTENT"
  end

  test "download requires authentication and paid skill access" do
    get skill_download_release_path(@skill, release_id: @release.id)
    assert_redirected_to new_user_session_path
    sign_in @member, scope: :user
    get skill_download_release_path(@skill, release_id: @release.id)
    assert_response :success
    assert_equal "PRIVATE_SKILL_CONTENT", response.body
    @member.update!(skills_access_until: Date.current - 1)
    get skill_download_release_path(@skill, release_id: @release.id)
    assert_redirected_to skills_path
  end

  test "release IDs cannot escape the requested skill" do
    other = Skill.create!(name: "Other", description: "Other", compatibility: "Markdown", published: true)
    sign_in @member, scope: :user
    get skill_download_release_path(other, release_id: @release.id)
    assert_response :not_found
  end

  test "member cannot change another group's profile" do
    sign_in @member, scope: :user
    patch member_group_path(@group), params: { group: { name: "Changed", owner_id: @member.id } }
    assert_response :not_found
    assert_equal "Vector test", @group.reload.name
  end

  test "a manager can confirm availability but cannot transfer ownership" do
    @group.group_managers.create!(user: @member)
    sign_in @member, scope: :user
    patch member_group_path(@group), params: { group: { owner_id: @member.id, city: "Bordeaux" } }
    assert_redirected_to member_group_path(@group)
    assert_equal @owner.id, @group.reload.owner_id
    post member_group_concert_availabilities_path(@group), params: { concert_availability: { date: Date.current, area_name: "Gironde", status: "available", confirmed_by_id: @owner.id } }
    assert_redirected_to member_group_path(@group)
    assert_equal @member.id, @group.concert_availabilities.last.confirmed_by_id
  end

  test "suspended ownership hides group and fresh dates from public listings" do
    @group.concert_availabilities.create!(date: Date.current, area_name: "Gironde", confirmed_by: @owner, confirmed_at: Time.current)
    get availabilities_path(date: Date.current.iso8601)
    assert_includes response.body, "Vector test"
    @owner.update!(active: false)
    get groups_path
    assert_not_includes response.body, "Vector test"
    get availabilities_path(date: Date.current.iso8601)
    assert_not_includes response.body, "Vector test"
  end

  test "stale and unavailable dates never appear as available" do
    @group.concert_availabilities.create!(date: Date.current, area_name: "Gironde", status: "unavailable", confirmed_by: @owner, confirmed_at: Time.current)
    @group.concert_availabilities.create!(date: Date.current, area_name: "Landes", confirmed_by: @owner, confirmed_at: 31.days.ago)
    get availabilities_path(date: Date.current.iso8601)
    assert_response :success
    assert_not_includes response.body, "Vector test"
  end

  test "non admins cannot manage memberships" do
    sign_in @member, scope: :user
    get admin_memberships_path
    assert_response :forbidden
  end
  test "public entry points and authentication forms render" do
    [root_path, groups_path, group_path(@group), availabilities_path, skills_path, new_user_session_path, new_user_registration_path, new_user_password_path].each do |path|
      get path
      assert_response :success
    end
    post user_session_path, params: { user: { email: @member.email, password: "secret-password" } }
    assert_redirected_to member_root_path
  end

  test "expired membership does not block free group management" do
    @member.membership.update!(starts_on: Date.current - 30, ends_on: Date.current - 1)
    sign_in @member, scope: :user
    get new_member_group_path
    assert_response :success
  end

  test "availability IDs cannot escape the selected group" do
    another = @member.owned_groups.create!(name: "Another", contact_email: @member.email)
    record = @group.concert_availabilities.create!(date: Date.current, area_name: "Gironde", confirmed_by: @owner, confirmed_at: Time.current)
    sign_in @member, scope: :user
    delete member_group_concert_availability_path(another, record)
    assert_response :not_found
    assert ConcertAvailability.exists?(record.id)
  end

  test "administration can grant then revoke paid skills independently" do
    @owner.update!(admin: true)
    sign_in @owner, scope: :user
    get admin_memberships_path
    assert_response :success
    get new_admin_skill_path
    assert_response :success
    get new_admin_skill_skill_release_path(@skill)
    assert_response :success
    patch admin_skill_access_path(@member), params: { user: { skills_access_until: "" } }
    assert_redirected_to admin_memberships_path
    assert_not @member.reload.skill_access?
    assert @member.membership.active?
  end

end
