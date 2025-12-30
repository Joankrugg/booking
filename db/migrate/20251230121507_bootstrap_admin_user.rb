class BootstrapAdminUser < ActiveRecord::Migration[8.0]
  def up
    User.find_by(email: "modernboxrecords@gmail.com")&.update!(admin: true)
  end
end