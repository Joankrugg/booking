class Member::DashboardController < Member::BaseController
  def index
    @groups = current_user.accessible_groups.order(:name)
  end
end
