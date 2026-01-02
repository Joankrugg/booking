class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  def require_active_subscription!
    redirect_to new_subscription_path unless current_user.subscription_status == "active"
  end

end
