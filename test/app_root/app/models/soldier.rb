class Soldier < ActiveRecord::Base

  has_role :name_accessor => "rank"

end
