class GeocodedPlace < ApplicationRecord
  validates :query_key, presence: true, uniqueness: true
  def located?
    latitude.present? && longitude.present?
  end
end
