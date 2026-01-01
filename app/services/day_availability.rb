# app/services/day_availability.rb
class DayAvailability
  SLOT_STEP_MINUTES = 15

  def initialize(date, services: nil)
    @date     = date
    @services = services || Service.all
  end

  # =========================
  # MOIS (calendrier)
  # =========================
  def build_month
    range = @date.beginning_of_month..@date.end_of_month
    slots = []

    # IMPORTANT : find_each only works on ActiveRecord::Relation
    services_relation.each do |service|
      range.each do |day|
        available_slots_for(service, day).each do |slot|
          slots << slot.merge(service: service)
        end
      end
    end

    slots
  end

  # =========================
  # JOUR UNIQUE (page résultats)
  # =========================
  def build
    services_relation.flat_map do |service|
      available_slots_for(service, @date).map { |slot| slot.merge(service: service) }
    end
  end

  private

  def services_relation
    # Au cas où quelqu’un passe un Array plus tard (ça arrive vite 😄)
    @services.respond_to?(:find_each) ? @services : Array(@services)
  end

  # =========================
  # LOGIQUE CENTRALE (par jour)
  # =========================
  def available_slots_for(service, day)
    rules = service.availability_rules.where(weekday: day.wday)
    return [] if rules.empty?

    rules.flat_map do |rule|
      build_slots_from_rule(service, rule, day)
    end
  end

  def build_slots_from_rule(service, rule, day)
    start_time = datetime_at(rule.start_time, day)
    end_time   = datetime_at(rule.end_time,   day)

    slots = []

    while start_time + service.duration_minutes.minutes <= end_time
      slot_end = start_time + service.duration_minutes.minutes

      unless overlaps_booking?(service, start_time, slot_end) ||
             overlaps_exception?(service, start_time, slot_end, day)
        slots << {
          start: start_time,
          end:   slot_end
        }
      end

      start_time += SLOT_STEP_MINUTES.minutes
    end

    slots
  end

  # =========================
  # CONFLITS
  # =========================
  def overlaps_booking?(service, start_time, end_time)
    # Filtre sur la journée pour éviter de scanner toute l’histoire de ta startup
    day_range = start_time.beginning_of_day..start_time.end_of_day

    service.bookings
           .where(start_time: day_range)
           .where("start_time < ? AND end_time > ?", end_time, start_time)
           .exists?
  end

  def overlaps_exception?(service, start_time, end_time, day)
    # availability_exceptions:
    # - date : date
    # - start_time : time (nullable)
    # - end_time   : time (nullable)
    #
    # règle :
    # - si start_time est null => exception commence au début de journée
    # - si end_time est null   => exception finit à fin de journée
    #
    # On compare avec des "time" (pas datetime) pour éviter les surprises PG.
    start_t = start_time.to_time
    end_t   = end_time.to_time

    service.availability_exceptions
           .where(date: day)
           .where(
             "(start_time IS NULL OR start_time < ?) AND (end_time IS NULL OR end_time > ?)",
             end_t,
             start_t
           )
           .exists?
  end

  # =========================
  # DATE + TIME SAFE
  # =========================
  def datetime_at(time, day)
    Time.zone.local(
      day.year,
      day.month,
      day.day,
      time.hour,
      time.min
    )
  end
end
