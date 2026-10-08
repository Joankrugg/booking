class Admin::MembershipsController < Admin::BaseController
  def index
    @users = User.includes(:membership).order(:email)
  end
  def create
    user = User.find(params[:user_id])
    @membership = user.membership || user.build_membership
    @membership.assign_attributes(membership_params)
    save_membership
  end
  def update
    @membership = Membership.find(params[:id])
    @membership.assign_attributes(membership_params)
    save_membership
  end
  private
  def membership_params
    params.require(:membership).permit(:starts_on, :ends_on, :status)
  end
  def save_membership
    if @membership.save
      redirect_to admin_memberships_path, notice: "Adhésion mise à jour."
    else
      redirect_to admin_memberships_path, alert: @membership.errors.full_messages.to_sentence
    end
  end
end
