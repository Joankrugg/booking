class Provider::ServicesController < Provider::BaseController
  def index
    @services = current_user.services.includes(:service_type)
  end

  def new
    @service = current_user.services.new
  end

  def create
    @service = current_user.services.new(service_params)
    if @service.save
      redirect_to provider_services_path, notice: "Prestation créée avec succès."
    else
      render :new, status: :unprocessable_entity
      Rails.logger.info "VALID? #{@service.valid?}"
      Rails.logger.info @service.errors.full_messages.inspect
    end
  end

  def edit
    @service = current_user.services.find(params[:id])
  end

  def update
    @service = current_user.services.find(params[:id])
    if @service.update(service_params)
      redirect_to provider_services_path, notice: "Prestation mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service = current_user.services.find(params[:id])
    @service.destroy
    redirect_to provider_services_path, notice: "Prestation supprimée."
  end

  private

  def service_params
    params.require(:service).permit(
      :name,
      :description,
      :price_euros,
      :duration_minutes,
      :service_type_id,
      :photo
    )
  end
end


