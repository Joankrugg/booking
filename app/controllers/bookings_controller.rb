class BookingsController < ApplicationController

  def new
    @service = Service.find(params[:service_id])
    @booking =  @service.bookings.new
  end

  def create
    @service = Service.find(params[:service_id])  # ← indispensable

    @booking = Booking.new(booking_params)

    if @booking.save
      redirect_to booking_path(@booking), notice: "Réservation enregistrée."
    else
      flash.now[:alert] = "Merci de compléter les informations."
      render "services/show", status: :unprocessable_entity
    end
  end



  def show
    @booking = Booking.find(params[:id])
  end

  private

  def booking_params
    params.require(:booking).permit(
      :service_id,
      :start_time,
      :end_time,
      :customer_name,
      :customer_email
    )
  end
end
