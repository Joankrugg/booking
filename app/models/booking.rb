class Booking < ApplicationRecord

  after_initialize do
    self.status ||= "pending"
  end

  belongs_to :service

  STATUSES = %w[pending confirmed cancelled].freeze

  validates :status, inclusion: { in: STATUSES }

  scope :blocking, -> { where(status: %w[pending confirmed]) }

  def self.overlapping?(service_id, start_time, end_time)
    blocking
      .where(service_id: service_id)
      .where("(start_time, end_time) OVERLAPS (?, ?)", start_time, end_time)
      .exists?
  end
end

