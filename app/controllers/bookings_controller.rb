class BookingsController < ApplicationController

  def new
    @service = Service.find(params[:service_id])

    @booking = @service.bookings.new(
      start_time: params[:start_time],
      end_time:   params[:end_time]
    )
  end

  def create
    @service = Service.find(params[:service_id])
    @booking = @service.bookings.new(booking_params)

    @booking.amount_cents = @service.price_euros * 100
    @booking.status = "pending"

    if @booking.save
      redirect_to success_service_booking_path(@service, @booking)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def success
    @booking = Booking.find(params[:id])
  end

  def cancel
    @booking = Booking.find(params[:id])
    @booking.update(status: "cancelled")
    redirect_to root_path
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
