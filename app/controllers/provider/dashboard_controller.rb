class Provider::DashboardController < Provider::BaseController
  def index
    @services = current_user.services
  end
end

