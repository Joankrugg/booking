class AddActiveToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :active, :boolean, null: false, default: true
  end
end
