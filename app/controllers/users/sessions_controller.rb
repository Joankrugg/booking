# frozen_string_literal: true
class Users::SessionsController < Devise::SessionsController
  layout "modern_box"
  def after_sign_in_path_for(resource)
    member_root_path
  end
end

