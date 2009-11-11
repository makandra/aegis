class VeteranSoldier < ActiveRecord::Base

  # Using legacy parameter names
  has_role :name_accessor => "rank"

end
