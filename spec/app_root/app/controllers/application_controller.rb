class ApplicationController < ActionController::Base
  include Aegis::Controller

  require_permissions

  def current_user
    nil # test missing_user_means
  end

end
