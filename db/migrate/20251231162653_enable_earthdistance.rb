class EnableEarthdistance < ActiveRecord::Migration[8.0]
  def up
    enable_extension "cube"
    enable_extension "earthdistance"
  end

  def down
    disable_extension "earthdistance"
    disable_extension "cube"
  end
end
