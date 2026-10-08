class Admin::BaseController < ApplicationController
  layout "modern_box"
  before_action { response.headers["Cache-Control"] = "private, no-store" }
  before_action :authenticate_user!
  before_action :admin_only!
  private
  def admin_only!
    head :forbidden unless current_user.admin?
  end
end
