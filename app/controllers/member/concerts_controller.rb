class Member::ConcertsController < Member::BaseController
  before_action :set_group
  before_action :set_concert, only: [ :edit, :update, :destroy ]
  def new
    @concert = @group.concerts.new(starts_at: Date.current.tomorrow.in_time_zone.change(hour: 20))
  end
  def create
    @concert = @group.concerts.new(concert_params)
    if @concert.save
      redirect_to member_group_path(@group), notice: "Concert enregistré."
    else
      render :new, status: :unprocessable_entity
    end
  end
  def edit; end
  def update
    if @concert.update(concert_params)
      redirect_to member_group_path(@group), notice: "Concert mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    @concert.destroy!
    redirect_to member_group_path(@group), notice: "Concert supprimé."
  end
  private
  def set_group
    @group = current_user.accessible_groups.find(params[:group_id])
  end
  def set_concert
    @concert = @group.concerts.find(params[:id])
  end
  def concert_params
    params.require(:concert).permit(:title, :starts_at, :venue_name, :city, :address, :description, :ticket_url, :published, :cancelled)
  end
end
