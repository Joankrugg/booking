require "geocoder/sql"
class GeographicSearch
  def self.filter(records, place, radius, touring: false)
    return records.none unless place&.located?
    max_radius = radius + (touring ? 1000 : 0)
    box = Geocoder::Calculations.bounding_box([place.latitude, place.longitude], max_radius, units: :km)
    table = records.klass.quoted_table_name
    candidates = records.where(Geocoder::Sql.within_bounding_box(*box, "#{table}.latitude", "#{table}.longitude"))
    if records.klass.connection.adapter_name == "PostgreSQL"
      # Production: compute exact distances in PostgreSQL, then paginate in SQL.
      distance = Geocoder::Sql.full_distance(place.latitude, place.longitude, "#{table}.latitude", "#{table}.longitude", units: :km)
      coverage = touring ? "#{radius.to_i} + #{table}.travel_radius_km" : radius.to_i.to_s
      return candidates.where("(#{distance}) <= #{coverage}")
    end
    # Portable SQLite test fallback: exact circle rather than Geocoder's square
    # approximation. No arbitrary candidate cap that could silently hide results.
    ids = []
    candidates.find_each do |record|
      distance = Geocoder::Calculations.distance_between([place.latitude, place.longitude], [record.latitude, record.longitude], units: :km)
      ids << record.id if distance <= radius + (touring ? record.travel_radius_km : 0)
    end
    records.where(id: ids)
  end
end
