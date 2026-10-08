class Admin::SkillReleasesController < Admin::BaseController
  before_action :set_skill
  before_action :set_release, only: [ :edit, :update, :destroy ]
  def index
    @releases = @skill.skill_releases.order(created_at: :desc)
  end
  def new
    @release = @skill.skill_releases.new
  end
  def create
    @release = @skill.skill_releases.new(release_params)
    if @release.save
      redirect_to admin_skill_skill_releases_path(@skill), notice: "Version ajoutée."
    else
      render :new, status: :unprocessable_entity
    end
  end
  def edit; end
  def update
    if @release.update(release_params)
      redirect_to admin_skill_skill_releases_path(@skill), notice: "Version mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    @release.destroy!
    redirect_to admin_skill_skill_releases_path(@skill), notice: "Version supprimée."
  end
  private
  def set_skill
    @skill = Skill.find(params[:skill_id])
  end
  def set_release
    @release = @skill.skill_releases.find(params[:id])
  end
  def release_params
    params.require(:skill_release).permit(:version, :instructions, :changelog)
  end
end
