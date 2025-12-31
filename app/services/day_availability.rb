# app/services/day_availability.rb
class DayAvailability
  SLOT_STEP_MINUTES = 15

  def initialize(date, services: Service.all)
    @date = date
    @services = services
  end

  def build
    @services.flat_map do |service|
      slots_for(service)
    end
  end

  private

  def slots_for(service)
    rules = service.availability_rules.where(weekday: @date.wday)
    return [] if rules.empty?

    rules.flat_map do |rule|
      build_slots_from_rule(service, rule)
    end
  end

  def build_slots_from_rule(service, rule)
    start_time = datetime_at(rule.start_time)
    end_time   = datetime_at(rule.end_time)

    slots = []

    while start_time + service.duration_minutes.minutes <= end_time
      slot_end = start_time + service.duration_minutes.minutes

      unless overlaps_booking?(service, start_time, slot_end) ||
             overlaps_exception?(service, start_time, slot_end)
        slots << {
          service: service,
          start: start_time,
          end: slot_end
        }
      end

      start_time += SLOT_STEP_MINUTES.minutes
    end

    slots
  end

  def overlaps_booking?(service, start_time, end_time)
    service.bookings
           .where("start_time < ? AND end_time > ?", end_time, start_time)
           .exists?
  end

  def overlaps_exception?(service, start_time, end_time)
    service.availability_exceptions
           .where(date: @date)
           .where(
             "(start_time IS NULL OR start_time < ?) AND
              (end_time IS NULL OR end_time > ?)",
             end_time.to_time,
             start_time.to_time
           )
           .exists?
  end

  def datetime_at(time)
    Time.zone.local(
      @date.year,
      @date.month,
      @date.day,
      time.hour,
      time.min
    )
  end
end
