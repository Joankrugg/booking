class Membership < ApplicationRecord
  belongs_to :user
  validates :starts_on, :ends_on, presence: true
  validates :status, inclusion: { in: %w[active revoked] }
  validate :ordered_dates
  scope :current, -> { where(status: "active").where("starts_on <= ? AND ends_on >= ?", Date.current, Date.current) }
  def active?
    status == "active" && starts_on.present? && ends_on.present? && starts_on <= Date.current && ends_on >= Date.current
  end
  private
  def ordered_dates
    errors.add(:ends_on, "doit suivre le début") if starts_on && ends_on && ends_on < starts_on
  end
end
