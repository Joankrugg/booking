class CalendarController < ApplicationController
  layout "calendar"

  def door
  end

  def index

    # ---- filtres
    @selected_categories = params[:categories]&.map(&:to_i) || []
    @location            = params[:location].to_s.strip.presence
    @date =
      begin
        Date.parse(params[:date].to_s.delete('"'))
      rescue ArgumentError
        Date.today
      end

    # ---- UI
    @categories = Category.order(:name)
    @calendar_days = build_calendar_days

    # ---- base services
    services = Service.includes(:category, :service_areas, :user).where(active: true).where(users: { active: true }).references(:user)


    if @selected_categories.any?
      services = services.where(category_id: @selected_categories)
    end

    if @location
      services = services
        .joins(:service_areas)
        .where("service_areas.address ILIKE ?", "%#{@location}%")
    end

    services = services.distinct

    services = services.select { |service| service.reservable_on?(@date) }

    # ---- DISPONIBILITÉS DU JOUR UNIQUEMENT
    day_slots = DayAvailability.new(@date, services: services).build

    @slots_by_service = day_slots.select { |slot| slot[:service].present? }.group_by { |slot| slot[:service] }
  end

  private

  def build_calendar_days
    MonthBuilder.new(@date).build
  end
end
