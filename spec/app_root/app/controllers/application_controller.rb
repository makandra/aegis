class ApplicationController < ActionController::Base

  require_permissions

  def current_user
    User.new(:role_name => 'user')
  end

end
