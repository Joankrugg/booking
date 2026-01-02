class Service < ApplicationRecord
  belongs_to :user
  belongs_to :service_type
  belongs_to :category, optional: true


  has_many :service_areas, dependent: :destroy
  has_many :availability_rules, dependent: :destroy
  has_many :availability_exceptions, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validates :name, presence: true
  validates :price_euros, numericality: true
  validates :duration_minutes, numericality: true

  has_one_attached :photo 
  def publishable?
    user.stripe_connected? && user.subscription_status == "active"
  end
  def reservable_from
    Date.today + min_notice_days
  end

  def reservable_on?(date)
    date >= reservable_from
  end
end

