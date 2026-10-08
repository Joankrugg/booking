class Users::RegistrationsController < Devise::RegistrationsController
  layout "modern_box"
  before_action :configure_profile_params, only: [:create, :update]
  def new
    build_resource(profile_type: User::PROFILE_TYPES.values.include?(params[:profile]) ? params[:profile] : "audience")
    resource.uses_groups = resource.profile_type == "artist"
    resource.uses_organizing = resource.profile_type == "organizer"
    resource.uses_concerts = resource.profile_type == "audience"
    yield resource if block_given?
    respond_with resource
  end
  protected
  def configure_profile_params
    fields = [:usage_choices_submitted, :uses_groups, :uses_organizing, :uses_concerts, :organizer_type, :organization_name, :profile_details]
    devise_parameter_sanitizer.permit(:sign_up, keys: fields)
    devise_parameter_sanitizer.permit(:account_update, keys: fields)
  end
  def after_sign_up_path_for(resource)
    member_root_path
  end
  def after_update_path_for(resource)
    member_root_path
  end
end
