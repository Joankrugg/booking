class Provider::ServiceAreasController < Provider::BaseController
  before_action :set_service

  def index
    @areas = @service.service_areas
  end

  def new
    @area = @service.service_areas.new
  end

  def create
    @area = @service.service_areas.new(area_params)
    if @area.save
      redirect_to provider_service_service_areas_path(@service), notice: "Zone ajoutée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @area = @service.service_areas.find(params[:id])
  end

  def update
    @area = @service.service_areas.find(params[:id])
    if @area.update(area_params)
      redirect_to provider_service_service_areas_path(@service), notice: "Zone mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @area = @service.service_areas.find(params[:id])
    @area.destroy
    redirect_to provider_service_service_areas_path(@service), notice: "Zone supprimée."
  end

  private

  def set_service
    @service = current_user.services.find(params[:service_id])
  end

  def area_params
    params.require(:service_area).permit(:address, :radius_km)
  end
end


