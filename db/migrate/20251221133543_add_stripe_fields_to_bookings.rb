class AddStripeFieldsToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :amount_cents, :integer
    add_column :bookings, :checkout_session_id, :string
    add_column :bookings, :payment_intent_id, :string
  end
end
