module Provider
  class DashboardController < BaseController
    def index
      @services_count = current_user.services.count
    end
  end
end
