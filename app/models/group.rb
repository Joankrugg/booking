require "uri"

class Group < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :concerts, dependent: :destroy
  has_many :group_managers, dependent: :destroy
  has_many :managers, through: :group_managers, source: :user
  has_many :concert_availabilities, dependent: :destroy
  validates :name, :contact_email, presence: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :member_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :safe_social_urls
  scope :publicly_visible, -> { joins(:owner).where(published: true, users: { active: true }) }
  def visible?
    published? && owner.active?
  end
  private
  def safe_social_urls
    %i[instagram_url youtube_url tiktok_url].each do |field|
      value = public_send(field)
      next if value.blank?
      uri = URI.parse(value)
      errors.add(field, "doit être une URL HTTPS valide") unless uri.scheme == "https" && uri.host.present? && uri.userinfo.nil?
    rescue URI::InvalidURIError
      errors.add(field, "est invalide")
    end
  end
end
