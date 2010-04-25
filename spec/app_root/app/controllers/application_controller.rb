class ApplicationController < ActionController::Base

  def current_user
    User.new(:role_name => 'user')
  end

end
