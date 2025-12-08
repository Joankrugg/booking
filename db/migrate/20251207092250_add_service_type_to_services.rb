class AddServiceTypeToServices < ActiveRecord::Migration[8.0]
  def change
    add_reference :services, :service_type, null: false, foreign_key: true
  end
end
