namespace :modern_box do
  desc "Localiser les concerts et disponibilités existants sans coordonnées (requêtes espacées)"
  task geocode_existing: :environment do
    count = 0
    [ConcertAvailability, Concert].each do |model|
      model.where(latitude: nil).find_each do |record|
        query = record.is_a?(Concert) ? [record.address, record.city].reject(&:blank?).join(", ") : record.area_name
        place = PlaceResolver.resolve(query)
        if place&.located?
          record.update_columns(latitude: place.latitude, longitude: place.longitude)
          count += 1
        end
        sleep 1.1
      end
    end
    puts "#{count} date(s) localisée(s). Les lieux non reconnus restent à préciser."
  end
end
