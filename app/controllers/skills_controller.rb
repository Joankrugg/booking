class SkillsController < ApplicationController
  layout "modern_box"
  before_action :authenticate_user!, only: [:download]
  before_action :require_skill_access!, only: [:download]
  def index
    @skills = Skill.published.order(:name)
  end
  def show
    @skill = Skill.published.find(params[:id])
    @releases = @skill.skill_releases.order(created_at: :desc)
  end
  def download
    skill = Skill.published.find(params[:skill_id])
    release = skill.skill_releases.find(params[:release_id])
    response.headers["Cache-Control"] = "private, no-store"
    send_data release.instructions, filename: "#{skill.name.parameterize}-#{release.version.parameterize}-SKILL.md", type: "text/markdown", disposition: "attachment"
  end
  private
  def require_skill_access!
    return if current_user.skill_access?
    redirect_to skills_path, alert: "Le téléchargement nécessite un accès Skills IA payant actif."
  end
end
