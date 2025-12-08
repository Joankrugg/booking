module Provider
  class BaseController < ApplicationController
    before_action :authenticate_user!
    layout "provider"
  end
end
