class ServiceArea < ApplicationRecord
  belongs_to :service

  geocoded_by :address
  validates :radius_km, presence: true

end
