class VeteranSoldier < ActiveRecord::Base

  # Use legacy parameter :name_accessor instead of :accessor
  has_role :name_accessor => "rank"

end
