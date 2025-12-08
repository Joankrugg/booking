class AddDefaultLocationTypeToServices < ActiveRecord::Migration[8.0]
  def change
    change_column_default :services, :location_type, from: nil, to: 0
  end
end
