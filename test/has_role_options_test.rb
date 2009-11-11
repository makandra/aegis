require "test/test_helper"

class HasRoleOptionsTest < ActiveSupport::TestCase

  context "A record with a custom role field" do

    setup do 
      @soldier = Soldier.new
    end
    
    should "allow its role to be written and read" do
      @soldier.role = "guest"
      assert_equal :guest, @soldier.role.name
    end
    
    should "store the role name in the custom field" do
      @soldier.role = "guest"
      assert_equal "guest", @soldier.rank
    end
    
    should "still work with permissions" do
      @soldier.role = "guest"
      assert @soldier.may_hug?
      assert !@soldier.may_update_users?
    end
    
  end

  context "A record wiring up its role using legacy parameter names" do

    setup do 
      @vetaran_soldier = VeteranSoldier.new
    end
    
    should "allow its role to be written and read" do
      @vetaran_soldier.role = "guest"
      assert_equal :guest, @vetaran_soldier.role.name
    end
    
  end
  
  context "A record with a default role" do
  
    should "create new instances with that role" do
      assert_equal :admin, TrustFundKid.new.role.name
    end
  
    should "ignore the default if another role is given" do
      assert_equal :student, TrustFundKid.new(:role_name => "student").role.name
    end
    
    should "not update existing records with the default role" do
      kid = TrustFundKid.create!(:role_name => "student")
      kid.update_attributes(:account_balance => 10_000_000)
      assert_equal :student, kid.reload.role.name
    end
  
  end

end
