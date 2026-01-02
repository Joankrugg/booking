class AddMinNoticeDaysToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :min_notice_days, :integer, null: false, default: 0
  end
end
