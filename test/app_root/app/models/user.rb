class User < ActiveRecord::Base

  has_role
  validates_role_name

end
