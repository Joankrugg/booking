class Member::ConcertAvailabilitiesController < Member::BaseController
  before_action :set_group
  before_action :set_availability, only: [ :edit, :update, :destroy ]
  def index
    redirect_to member_group_path(@group)
  end
  def new
    @availability = @group.concert_availabilities.new(date: Date.current, area_name: @group.city)
  end
  def create
    @availability = @group.concert_availabilities.new(availability_params)
    stamp_confirmation
    if @availability.save
      redirect_to member_group_path(@group), notice: "Disponibilité confirmée."
    else
      render :new, status: :unprocessable_entity
    end
  end
  def edit; end
  def update
    @availability.assign_attributes(availability_params)
    stamp_confirmation
    if @availability.save
      redirect_to member_group_path(@group), notice: "Disponibilité reconfirmée."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    @availability.destroy!
    redirect_to member_group_path(@group), notice: "Date supprimée."
  end
  private
  def set_group
    @group = current_user.accessible_groups.find(params[:group_id])
  end
  def set_availability
    @availability = @group.concert_availabilities.find(params[:id])
  end
  def availability_params
    params.require(:concert_availability).permit(:date, :status, :area_name, :public_note, :travel_radius_km, :starts_at_time, :ends_at_time)
  end
  def stamp_confirmation
    @availability.confirmed_by = current_user
    @availability.confirmed_at = Time.current
  end
end
