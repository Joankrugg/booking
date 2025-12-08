class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.integer :price_euros
      t.integer :duration_minutes
      t.string :location_type

      t.timestamps
    end
  end
end
