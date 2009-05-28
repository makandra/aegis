require "test/test_helper"

class HasRoleTest < ActiveSupport::TestCase

  context "Objects that have an aegis role" do

    setup do 
      @guest = User.new(:role_name => "guest")
      @student = User.new(:role_name => "student")
      @admin = User.new(:role_name => "admin")
    end
    
    should "know their role" do
      assert :guest, @guest.role.name
      assert :student, @student.role.name
      assert :admin, @admin.role.name
    end
    
    should "know if they belong to a role" do
      assert @guest.guest?
      assert !@guest.student?
      assert !@guest.admin?
      assert !@student.guest?
      assert @student.student?
      assert !@student.admin?
      assert !@admin.guest?
      assert !@admin.student?
      assert @admin.admin?
    end
    
    should "still behave as usual when a method ending in a '?' does not map to a role query" do
      assert_raise NoMethodError do
        @guest.nonexisting_method?
      end
    end
    
  end

end
