class CreateAvailabilityRules < ActiveRecord::Migration[8.0]
  def change
    create_table :availability_rules do |t|
      t.references :service, null: false, foreign_key: true
      t.integer :weekday
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end
end
