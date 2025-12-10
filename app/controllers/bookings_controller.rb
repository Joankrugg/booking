class BookingsController < ApplicationController

  def new
    @service = Service.find(params[:service_id])

    @booking = Booking.new(
      service_id: @service.id,
      start_time: params[:start_time],
      end_time: params[:end_time]
    )
  end

  def create
    @booking = Booking.new(booking_params)

    if @booking.save
      redirect_to booking_path(@booking), notice: "Réservation enregistrée."
    else
      redirect_back fallback_location: service_path(params[:service_id]), alert: "Impossible de créer la réservation."
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
