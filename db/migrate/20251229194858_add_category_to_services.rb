class AddCategoryToServices < ActiveRecord::Migration[8.0]
  def change
    add_reference :services, :category, foreign_key: true
  end
end