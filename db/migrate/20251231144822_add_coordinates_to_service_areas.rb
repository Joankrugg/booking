class AddCoordinatesToServiceAreas < ActiveRecord::Migration[8.0]
  def change
    add_column :service_areas, :latitude, :float
    add_column :service_areas, :longitude, :float
  end
end
