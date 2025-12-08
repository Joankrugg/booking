class Provider::AvailabilityExceptionsController < Provider::BaseController
  before_action :set_service
  before_action :set_exception, only: [:edit, :update, :destroy]

  def index
    @exceptions = @service.availability_exceptions.order(:date)
  end

  def new
    @exception = @service.availability_exceptions.new
  end

  def create
    @exception = @service.availability_exceptions.new(exception_params)
    if @exception.save
      redirect_to provider_service_availability_exceptions_path(@service),
        notice: "Exception ajoutée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @exception.update(exception_params)
      redirect_to provider_service_availability_exceptions_path(@service),
        notice: "Exception mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @exception.destroy
    redirect_to provider_service_availability_exceptions_path(@service),
      notice: "Exception supprimée."
  end

  private

  def set_service
    @service = current_user.services.find(params[:service_id])
  end

  def set_exception
    @exception = @service.availability_exceptions.find(params[:id])
  end

  def exception_params
    params.require(:availability_exception).permit(:date, :start_time, :end_time)
  end
end
