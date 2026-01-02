class AddActiveToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :active, :boolean, null: false, default: true
  end
end
