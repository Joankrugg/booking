class CreateServiceAreas < ActiveRecord::Migration[8.0]
  def change
    create_table :service_areas do |t|
      t.references :service, null: false, foreign_key: true
      t.string :address
      t.integer :radius_km

      t.timestamps
    end
  end
end
