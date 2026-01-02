class Provider::ProfilesController < Provider::BaseController
  def toggle_active
    current_user.update!(active: !current_user.active)

    redirect_to provider_root_path,
      notice: current_user.active? ?
        "Votre activité est de nouveau active." :
        "Votre activité est mise en pause."
  end
end