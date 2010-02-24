require "test/test_helper"

class ValidationTest < ActiveSupport::TestCase

  context "A model that has and validates its role" do

    setup do 
      @user = User.new()
    end
    
    context "that has a role_name mapping to a role" do
      
      setup do
        @user.role_name = "admin"
      end
      
      should "be valid" do
        assert @user.valid?
      end
      
    end
    
    context "that has a blank role_name" do
      
      setup do
        @user.role_name = ""
      end
      
      should "not be valid" do
        assert !@user.valid?
      end
      
    end
    
    context "that has a role_name not mapping to a role" do
      
      setup do
        @user.role_name = "nonexisting_role_name"
      end
      
      should "not be valid" do
        assert !@user.valid?
      end
      
    end
    
    should "use add the default inclusion error message on role_name" do
      @user.role_name = ""
      @user.valid?
      assert_equal I18n.translate('activerecord.errors.messages.inclusion'), @user.errors.on(:role_name)
    end
    
  end

end
