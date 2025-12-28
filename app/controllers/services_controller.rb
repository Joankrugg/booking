# app/controllers/services_controller.rb
class ServicesController < ApplicationController
  def index
    @services = Service.all  
  end

  def show
    @service = Service.find(params[:id])

    @prefill_date  = params[:date]
    @prefill_start = params[:start]

    @booking = Booking.new(
      service: @service,
      start_time: @prefill_start,
      amount_cents: @service.price_euros
    )
  end


  # GET /services/:id/availability?date=2025-12-10
  def availability
    service = Service.find(params[:id])
    date    = params[:date].present? ? Date.parse(params[:date]) : Date.current

    slots = SlotEngine.new(service, date).call

    render json: {
      service_id: service.id,
      date: date.to_s,
      slots: slots.map { |s|
        {
          start: s[:start].iso8601,
          end:   s[:end].iso8601
        }
      }
    }
  end
  def success
    @service = Service.find(params[:service_id])
    @booking = @service.bookings.find(params[:id])
  end

  def cancel
    @service = Service.find(params[:service_id])
    @booking = @service.bookings.find(params[:id])
  end

end

