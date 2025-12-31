# app/controllers/calendar_controller.rb
class CalendarController < ApplicationController
  layout "calendar"
  def index
    @selected_categories = params[:categories]&.map(&:to_i) || []

    @categories = Category.order(:name)

    @date = params[:date]&.to_date || Date.today

    @calendar_days = MonthBuilder.new(@date).build

    services = Service.includes(:category)

    if params[:categories].present?
      services = services.where(category_id: params[:categories])
    end

    slots = DayAvailability.new(@date, services: services).build
    @slots_by_service = slots.group_by { |slot| slot[:service] }
  end

  def day
    redirect_to calendar_path(date: params[:date], categories: params[:categories])
  end
end

