class DayAvailability
  def initialize(date)
    @date = date
  end

  def build
    Service
      .includes(:availability_rules, :availability_exceptions, :bookings)
      .flat_map { |service| slots_for(service) }
  end

  private

  def slots_for(service)
    duration = service.duration_minutes.minutes

    service.availability_rules
           .where(weekday: @date.wday)
           .flat_map do |rule|
             build_slots_from_rule(service, rule, duration)
           end
  end

  def build_slots_from_rule(service, rule, duration)
    slots = []

    start_time = time_on_date(rule.start_time)
    end_time   = time_on_date(rule.end_time)

    cursor = start_time

    while (cursor + duration) <= end_time
      if slot_available?(service, cursor, duration)
        slots << {
          service: service,
          start: cursor,
          end:   cursor + duration
        }
      end

      # ✅ PAS MÉTIER : durée du service
      cursor += duration
    end

    slots
  end

  def slot_available?(service, start_time, duration)
    !booking_conflict?(service, start_time, duration) &&
      !exception_conflict?(service, start_time, duration)
  end

  def booking_conflict?(service, start_time, duration)
    service.bookings.where(
      "(start_time, end_time) OVERLAPS (?, ?)",
      start_time,
      start_time + duration
    ).exists?
  end

  def exception_conflict?(service, start_time, duration)
    service.availability_exceptions
       .where(date: start_time.to_date)
       .any? do |exception|
         exception_start = Time.zone.local(
           start_time.year,
           start_time.month,
           start_time.day,
           exception.start_time.hour,
           exception.start_time.min
         )

         exception_end = Time.zone.local(
           start_time.year,
           start_time.month,
           start_time.day,
           exception.end_time.hour,
           exception.end_time.min
         )

         ranges_overlap?(
           exception_start,
           exception_end,
           start_time,
           start_time + duration
         )
     end
  end
  
  def ranges_overlap?(a_start, a_end, b_start, b_end)
    a_start < b_end && b_start < a_end
  end


  def time_on_date(time)
    Time.zone.local(
      @date.year,
      @date.month,
      @date.day,
      time.hour,
      time.min
    )
  end
end
