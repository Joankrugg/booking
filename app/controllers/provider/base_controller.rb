class Provider::BaseController < ApplicationController
  before_action :authenticate_user!
  layout "provider"
end

