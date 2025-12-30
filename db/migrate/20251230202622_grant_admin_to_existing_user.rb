class GrantAdminToExistingUser < ActiveRecord::Migration[8.0]
  def up
    return unless column_exists?(:users, :admin)

    user = User.find_by(email: "modernboxrecords@gmail.com")
    user.update_column(:admin, true) if user
  end
end
