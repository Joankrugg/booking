class Member::GroupsController < Member::BaseController
  before_action :set_group, only: [ :show, :edit, :update, :destroy ]
  def index
    redirect_to member_root_path
  end
  def show
    @availabilities = @group.concert_availabilities.order(date: :desc).limit(100)
    @concerts = @group.concerts.order(starts_at: :desc)
    @managers = @group.group_managers.includes(:user)
  end
  def new
    @group = current_user.owned_groups.new(contact_email: current_user.email)
  end
  def create
    @group = current_user.owned_groups.new(group_params)
    if @group.save
      redirect_to member_group_path(@group), notice: "Groupe créé. Ajoutez ses dates et zones de déplacement."
    else
      render :new, status: :unprocessable_entity
    end
  end
  def edit; end
  def update
    if @group.update(group_params)
      redirect_to member_group_path(@group), notice: "Groupe mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    return head :forbidden unless current_user.admin? || @group.owner_id == current_user.id
    @group.destroy!
    redirect_to member_root_path, notice: "Groupe supprimé."
  end
  private
  def set_group
    @group = current_user.accessible_groups.find(params[:id])
  end
  def group_params
    params.require(:group).permit(:name, :genre, :description, :city, :member_count, :contact_email, :contact_phone, :instagram_url, :youtube_url, :tiktok_url, :published)
  end
end
