class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :service, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :customer_name
      t.string :customer_email
      t.string :status

      t.timestamps
    end
  end
end
