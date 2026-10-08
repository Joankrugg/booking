class Member::GroupManagersController < Member::BaseController
  before_action :set_group
  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user && user.active?
      @group.group_managers.find_or_create_by!(user: user)
      redirect_to member_group_path(@group), notice: "Responsable ajouté."
    else
      redirect_to member_group_path(@group), alert: "Le compte doit exister et être actif."
    end
  end
  def destroy
    @group.group_managers.find(params[:id]).destroy!
    redirect_to member_group_path(@group), notice: "Accès retiré."
  end
  private
  def set_group
    @group = current_user.accessible_groups.find(params[:group_id])
    head :forbidden unless current_user.admin? || @group.owner_id == current_user.id
  end
end
