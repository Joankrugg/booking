# app/controllers/calendar_controller.rb
class CalendarController < ApplicationController
  def index
    @date = params[:date]&.to_date || Date.today

    @calendar_days = MonthBuilder.new(@date).build

    slots = DayAvailability.new(@date).build
    @slots_by_service = slots.group_by { |slot| slot[:service] }
  end

  def day
    @date = Date.parse(params[:date])
    @slots = DayAvailability.new(@date).build
    render :index
  end
end
