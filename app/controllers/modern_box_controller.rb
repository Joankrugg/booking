class ModernBoxController < ApplicationController
  layout "modern_box"
  def index
    @groups = Group.publicly_visible.order(:name).limit(6)
  end
end
