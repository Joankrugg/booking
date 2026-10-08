class Member::BaseController < ApplicationController
  layout "modern_box"
  before_action { response.headers["Cache-Control"] = "private, no-store" }
  before_action :authenticate_user!
end
