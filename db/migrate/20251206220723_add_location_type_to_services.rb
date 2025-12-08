class AddLocationTypeToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :location_type, :integer
  end
end
