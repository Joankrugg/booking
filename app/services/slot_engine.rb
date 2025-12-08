class SlotEngine
  def initialize(service, date)
    @service = service
    @date = date.is_a?(Date) ? date : Date.parse(date.to_s)
  end

  def call
    slots = base_slots
    slots = apply_exceptions(slots)
    # slots = apply_bookings(slots) si tu ajoutes un modèle Booking plus tard
    slots
  end

  private

  def base_slots
    rules = @service.availability_rules.where(weekday: @date.wday)
    return [] if rules.empty?

    rules.flat_map { |rule| build_slots_for_rule(rule) }
  end

  def build_slots_for_rule(rule)
    slot_minutes = @service.duration_minutes.to_i
    return [] if slot_minutes <= 0

    start_dt = time_on_date(@date, rule.start_time)
    end_dt   = time_on_date(@date, rule.end_time)

    slots = []
    current_start = start_dt

    while current_start + slot_minutes.minutes <= end_dt
      slots << {
        start: current_start,
        end:   current_start + slot_minutes.minutes
      }
      current_start += slot_minutes.minutes
    end

    slots
  end

  def apply_exceptions(slots)
    exceptions = @service.availability_exceptions.where(date: @date)
    return slots if exceptions.empty?

    slots.reject do |slot|
      exceptions.any? do |ex|
        ex_start, ex_end = exception_range(ex)
        ranges_overlap?(slot[:start], slot[:end], ex_start, ex_end)
      end
    end
  end

  # Hook futur si tu ajoutes un modèle Booking
  #
  # def apply_bookings(slots)
  #   bookings = Booking.where(service: @service, start_time: @date.beginning_of_day..@date.end_of_day)
  #   slots.reject do |slot|
  #     bookings.any? do |b|
  #       ranges_overlap?(slot[:start], slot[:end], b.start_time, b.end_time)
  #     end
  #   end
  # end

  def exception_range(ex)
    if ex.start_time && ex.end_time
      [
        time_on_date(@date, ex.start_time),
        time_on_date(@date, ex.end_time)
      ]
    else
      [
        @date.beginning_of_day.in_time_zone,
        @date.end_of_day.in_time_zone
      ]
    end
  end

  def time_on_date(date, time)
    Time.zone.local(date.year, date.month, date.day, time.hour, time.min)
  end

  def ranges_overlap?(a_start, a_end, b_start, b_end)
    a_start < b_end && b_start < a_end
  end
end
