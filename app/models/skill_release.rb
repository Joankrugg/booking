class SkillRelease < ApplicationRecord
  belongs_to :skill
  validates :version, :instructions, presence: true
  validates :version, uniqueness: { scope: :skill_id }
  validates :instructions, length: { maximum: 500_000 }
end
