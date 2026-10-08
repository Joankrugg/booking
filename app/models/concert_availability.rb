class ConcertAvailability < ApplicationRecord
  include LocatedRecord
  STATUSES = { "Disponible" => "available", "Sur demande" => "on_request", "Indisponible" => "unavailable" }.freeze
  belongs_to :group
  belongs_to :confirmed_by, class_name: "User"
  before_validation :normalize_area
  validates :date, :area_name, :area_key, :confirmed_at, presence: true
  validates :status, inclusion: { in: STATUSES.values }
  validates :area_key, uniqueness: { scope: [ :group_id, :date ] }
  validates :travel_radius_km, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1000 }
  validate :valid_time_window
  validates :area_name, length: { maximum: 200 }
  validates :public_note, length: { maximum: 1000 }
  scope :bookable, -> { where(status: %w[available on_request]) }
  scope :fresh, -> { where("confirmed_at >= ?", 30.days.ago) }
  def status_label
    STATUSES.key(status)
  end
  private
  def location_query
    area_name
  end
  def location_changed?
    will_save_change_to_area_name?
  end
  def valid_time_window
    if starts_at_time.present? != ends_at_time.present?
      errors.add(:base, "Renseignez les deux horaires ou aucun.")
    elsif starts_at_time && ends_at_time && ends_at_time <= starts_at_time
      errors.add(:ends_at_time, "doit être après le début (créneau sur la même journée).")
    end
  end
  def normalize_area
    self.area_name = area_name.to_s.strip
    self.area_key = area_name.parameterize
  end
end
