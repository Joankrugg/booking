class Admin::SkillAccessesController < Admin::BaseController
  def update
    user = User.find(params[:id])
    if user.update(params.require(:user).permit(:skills_access_until))
      redirect_to admin_memberships_path, notice: "Accès Skills IA mis à jour."
    else
      redirect_to admin_memberships_path, alert: user.errors.full_messages.to_sentence
    end
  end
end
