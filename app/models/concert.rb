require "uri"
class Concert < ApplicationRecord
  include LocatedRecord
  belongs_to :group
  before_validation { self.city_key = city.to_s.parameterize }
  validates :title, :starts_at, :venue_name, :city, presence: true
  validates :city, length: { maximum: 100 }
  validates :address, length: { maximum: 100 }
  validates :description, length: { maximum: 10_000 }
  validate :safe_ticket_url
  scope :publicly_visible, -> { joins(:group).merge(Group.publicly_visible).where(published: true) }
  private
  def location_query
    [address, city].reject(&:blank?).join(", ")
  end
  def location_changed?
    will_save_change_to_city? || will_save_change_to_address?
  end
  def safe_ticket_url
    return if ticket_url.blank?
    uri = URI.parse(ticket_url)
    errors.add(:ticket_url, "doit être une URL HTTPS valide") unless uri.scheme == "https" && uri.host.present? && uri.userinfo.nil?
  rescue URI::InvalidURIError
    errors.add(:ticket_url, "est invalide")
  end
end
