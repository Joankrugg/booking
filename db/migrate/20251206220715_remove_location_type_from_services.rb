class RemoveLocationTypeFromServices < ActiveRecord::Migration[8.0]
  def change
    remove_column :services, :location_type, :string
  end
end
