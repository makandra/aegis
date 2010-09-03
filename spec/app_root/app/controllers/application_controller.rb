class ApplicationController < ActionController::Base
  include Aegis::Controller

  require_permissions

  def current_user
    User.new(:role_name => 'user')
  end

end
