class Skill < ApplicationRecord
  has_many :skill_releases, dependent: :destroy
  validates :name, :description, :compatibility, presence: true
  scope :published, -> { where(published: true) }
end
