# app/models/booking.rb
class Booking < ApplicationRecord
  belongs_to :service

  validates :start_time, :end_time, :customer_name, :customer_email, presence: true

  # tout simple pour l’instant
  STATUSES = %w[pending confirmed cancelled].freeze

  validates :status, inclusion: { in: STATUSES }
end
