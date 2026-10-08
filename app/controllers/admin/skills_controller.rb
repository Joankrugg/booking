class Admin::SkillsController < Admin::BaseController
  before_action :set_skill, only: [ :show, :edit, :update, :destroy ]
  def index
    @skills = Skill.order(:name)
  end
  def show
    redirect_to admin_skill_skill_releases_path(@skill)
  end
  def new
    @skill = Skill.new
  end
  def create
    @skill = Skill.new(skill_params)
    if @skill.save
      redirect_to admin_skill_skill_releases_path(@skill), notice: "Skill créé. Ajoutez une version."
    else
      render :new, status: :unprocessable_entity
    end
  end
  def edit; end
  def update
    if @skill.update(skill_params)
      redirect_to admin_skills_path, notice: "Skill mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    @skill.destroy!
    redirect_to admin_skills_path, notice: "Skill supprimé."
  end
  private
  def set_skill
    @skill = Skill.find(params[:id])
  end
  def skill_params
    params.require(:skill).permit(:name, :description, :compatibility, :published)
  end
end
