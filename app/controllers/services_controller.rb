# app/controllers/services_controller.rb
class ServicesController < ApplicationController
  def show
    @service = Service.find(params[:id])
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
end
