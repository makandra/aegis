require "test/test_helper"

class HasRoleOptionsTest < ActiveSupport::TestCase

  context "A record with a custom role field" do

    setup do 
      @soldier = Soldier.new
    end
    
    should "allow its role to be written and read" do
      @soldier.role = "guest"
      assert "guest", @soldier.role.name
    end
    
    should "store the role name in the custom field" do
      assert "guest", @soldier.rank
    end
    
    should "still work with permissions" do
      @soldier.role = "guest"
      assert @soldier.may_hug?
      assert !@soldier.may_update_users?
    end
    
  end

end
