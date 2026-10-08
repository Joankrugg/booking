# Persistent cache and a database-wide gate. No autocomplete.
class PlaceResolver
  def self.resolve(text)
    query = text.to_s.strip
    return if query.blank? || query.length > 220
    country = ENV.fetch("GEOCODER_COUNTRY", "France")
    key = "#{country.parameterize}:#{query.parameterize}"
    cached = GeocodedPlace.find_by(query_key: key)
    return cached if cached && (cached.located? || cached.looked_up_at && cached.looked_up_at > 30.minutes.ago)
    gate = GeocodingGate.create_or_find_by!(id: 1)
    allowed = gate.with_lock do
      if gate.requested_at && gate.requested_at > 1.second.ago
        false
      else
        gate.update!(requested_at: Time.current)
        true
      end
    end
    return unless allowed
    result = Geocoder.search([query, country].reject(&:blank?).join(", ")).first
    place = cached || GeocodedPlace.create_or_find_by!(query_key: key)
    coordinates = result&.coordinates
    valid = coordinates&.length == 2 && coordinates.all? { |value| value.is_a?(Numeric) && value.finite? } && coordinates[0].between?(-90, 90) && coordinates[1].between?(-180, 180)
    place.update!(label: query, latitude: valid ? coordinates[0] : nil,
      longitude: valid ? coordinates[1] : nil, looked_up_at: Time.current)
    place
  rescue Geocoder::Error, Timeout::Error, SocketError => error
    Rails.logger.warn("Geocoding unavailable: #{error.class}")
    nil
  end
end
