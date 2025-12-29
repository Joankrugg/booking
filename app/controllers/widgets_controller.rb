class WidgetsController < ApplicationController
  layout "widget"

  def calendar
    @provider = User.find(params[:provider_id])
    @date = params[:date]&.to_date || Date.today

    slots = DayAvailability.new(@date).build
    slots = slots.select { |s| s[:service].user_id == @provider.id }

    @slots_by_service = slots.group_by { |s| s[:service] }
  end
end
