# app/controllers/bookings_controller.rb
class BookingsController < ApplicationController
  def create
    @booking = Booking.new(booking_params)

    if @booking.save
      redirect_to booking_path(@booking), notice: "Réservation enregistrée."
    else
      # on pourrait faire mieux, mais pour MVP :
      redirect_back fallback_location: root_path, alert: "Impossible de créer la réservation."
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
