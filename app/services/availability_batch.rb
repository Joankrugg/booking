class AvailabilityBatch
  class Invalid < StandardError; end
  MAX_DAYS = 366
  def self.apply(group:, user:, dates:, attributes:, clear: false)
    dates = dates.uniq
    raise Invalid, "Choisissez entre 1 et 366 dates." unless dates.size.between?(1, MAX_DAYS)
    raise Invalid, "Une date passée ne peut pas être déclarée." if dates.any? { |date| date < Date.current }
    probe = group.concert_availabilities.new(attributes.merge(date: dates.first, confirmed_by: user, confirmed_at: Time.current))
    probe.send(:normalize_area)
    raise Invalid, "Indiquez une ville de départ." if probe.area_key.blank?
    PlaceResolver.resolve(probe.area_name) unless clear
    group.with_lock do
      dates.each do |day|
        record = group.concert_availabilities.find_or_initialize_by(date: day, area_key: probe.area_key)
        if clear
          record.destroy! if record.persisted?
        else
          record.assign_attributes(attributes.merge(confirmed_by: user, confirmed_at: Time.current))
          record.save!
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => error
    raise Invalid, error.record.errors.full_messages.join(". ")
  end
end
