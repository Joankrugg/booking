class AddStripeConnectToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :stripe_account_id, :string
    add_column :users, :stripe_connected, :boolean, default: false

    add_column :users, :stripe_customer_id, :string
    add_column :users, :subscription_status, :string
  end
end
