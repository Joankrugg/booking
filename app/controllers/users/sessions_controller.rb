# frozen_string_literal: true
class Users::SessionsController < Devise::SessionsController
  layout "login"
  def after_sign_in_path_for(resource)
    provider_root_path
  end
end

