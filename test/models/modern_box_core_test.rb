require "test_helper"
class ModernBoxCoreTest < ActiveSupport::TestCase
  test "membership dates are inclusive and revocation overrides dates" do
    user = User.create!(email: "dates@example.test", password: "secret-password", active: true)
    membership = user.membership
    membership.update!(starts_on: Date.current, ends_on: Date.current)
    assert membership.active?
    membership.update!(status: "revoked")
    assert_not membership.active?
  end
  test "area names normalize before uniqueness validation" do
    user = User.create!(email: "areas@example.test", password: "secret-password", active: true)
    group = user.owned_groups.create!(name: "Test", contact_email: user.email)
    group.concert_availabilities.create!(date: Date.current, area_name: " Gironde ", confirmed_by: user, confirmed_at: Time.current)
    duplicate = group.concert_availabilities.new(date: Date.current, area_name: "GIRONDE", confirmed_by: user, confirmed_at: Time.current)
    assert_not duplicate.valid?
    assert_includes duplicate.errors.attribute_names, :area_key
  end
end
