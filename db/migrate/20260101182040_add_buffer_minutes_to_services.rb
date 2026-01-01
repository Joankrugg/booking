class AddBufferMinutesToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :buffer_minutes, :integer, default: 0, null: false
  end
end
