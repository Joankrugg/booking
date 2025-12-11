class Booking < ApplicationRecord

  after_initialize do
    self.status ||= "pending"
  end

  belongs_to :service

  STATUSES = %w[pending confirmed cancelled].freeze

  validates :status, inclusion: { in: STATUSES }


end
