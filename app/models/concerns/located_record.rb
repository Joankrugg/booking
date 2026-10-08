module LocatedRecord
  extend ActiveSupport::Concern
  included do
    before_save :resolve_coordinates
  end
  private
  def resolve_coordinates
    return unless new_record? || location_changed? || latitude.nil? || longitude.nil?
    place = PlaceResolver.resolve(location_query)
    self.latitude = place&.latitude
    self.longitude = place&.longitude
  end
end
