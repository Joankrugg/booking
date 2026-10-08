class User < ApplicationRecord
  PROFILE_TYPES = { "Je représente un ou plusieurs groupes" => "artist", "Je programme des concerts" => "organizer", "Je cherche des concerts où sortir" => "audience" }.freeze
  ORGANIZER_TYPES = { "Gérant de salle" => "venue_manager", "Tourneur" => "tour_manager", "Programmateur / festival" => "promoter", "Autre organisateur" => "other" }.freeze
  attr_accessor :usage_choices_submitted
  after_create :create_automatic_membership!
  before_validation :sync_legacy_profile
  validate :at_least_one_use
  validates :profile_type, inclusion: { in: PROFILE_TYPES.values }
  validates :organizer_type, inclusion: { in: ORGANIZER_TYPES.values }, if: -> { uses_organizing? }
  validates :organization_name, :profile_details, length: { maximum: 1000 }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :services, dependent: :destroy
  has_one :membership, dependent: :destroy
  has_many :owned_groups, class_name: "Group", foreign_key: :owner_id, dependent: :destroy
  has_many :group_managers, dependent: :destroy
  has_many :managed_groups, through: :group_managers, source: :group
  has_many :confirmed_availabilities, class_name: "ConcertAvailability", foreign_key: :confirmed_by_id, dependent: :restrict_with_error

  def sync_legacy_profile
    if usage_choices_submitted != "1" && !uses_groups? && !uses_organizing? && !uses_concerts? && (new_record? || will_save_change_to_profile_type?)
      self.uses_groups = profile_type == "artist"
      self.uses_organizing = profile_type == "organizer"
      self.uses_concerts = profile_type == "audience"
    end
    self.profile_type = uses_groups? ? "artist" : (uses_organizing? ? "organizer" : "audience")
  end
  def at_least_one_use
    errors.add(:base, "Sélectionnez au moins un usage.") unless uses_groups? || uses_organizing? || uses_concerts?
  end

  def create_automatic_membership!
    create_membership!(starts_on: Date.current, ends_on: Date.new(9999, 12, 31), status: "active")
  end

  def skill_access?
    active? && (admin? || (skills_access_until.present? && skills_access_until >= Date.current))
  end

  def membership_active?
    active? && membership&.active? == true
  end

  def accessible_groups
    return Group.all if admin?
    Group.where(owner_id: id).or(Group.where(id: managed_groups.select(:id)))
  end

  def active_for_authentication?
    super && active?
  end
  def active?
    active
  end

end
