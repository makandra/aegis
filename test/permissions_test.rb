require "test/test_helper"

class PermissionsTest < ActiveSupport::TestCase

  context "Aegis permissions" do

    setup do 
      @guest = User.new(:role_name => "guest")
      @student = User.new(:role_name => "student")
      @admin = User.new(:role_name => "admin")
    end
    
    should "use the default permission for actions without any allow or grant directives" do
      assert !@guest.may_use_empty?
      assert !@student.may_use_empty?
      assert @admin.may_use_empty?
    end
    
    should "understand simple allow and deny directives" do
      assert !@guest.may_use_simple?
      assert @student.may_use_simple?
      assert !@admin.may_use_simple?
    end
    
    should 'raise exceptions when a denied action is queried with an exclamation mark' do
      assert_raise Aegis::PermissionError do
        @guest.may_use_simple!
      end
      assert_raise Aegis::PermissionError do
        @admin.may_use_simple!
      end
    end
    
    should 'do nothing if an allowed action is queried with an exclamation mark' do
      assert_nothing_raised do
        @student.may_use_simple!
      end
    end
    
    should "implicate the singular form of an action described in plural form" do
      assert !@guest.may_update_users?
      assert !@guest.may_update_user?("foo")
      assert @student.may_update_users?
      assert @student.may_update_user?("foo")
      assert !@admin.may_update_users?
      assert !@admin.may_update_user?("foo")
    end
    
    should 'implicate create, read, update and destroy forms for actions named "crud_..."' do
      assert @student.may_create_projects?
      assert @student.may_read_projects?
      assert @student.may_update_projects?
      assert @student.may_destroy_projects?
    end
    
    should 'perform normalization of CRUD verbs (e.g. "edit" and "update")' do
      assert !@guest.may_edit_drinks?
      assert @student.may_edit_drinks?
      assert !@admin.may_edit_drinks?
      assert !@guest.may_update_drinks?
      assert @student.may_update_drinks?
      assert !@admin.may_update_drinks?
    end
    
    should "be able to grant or deny actions to all roles using :everyone" do
      assert @guest.may_hug?
      assert @student.may_hug?
      assert @admin.may_hug?
    end
    
    should "allow the definition of parametrized actions" do
      assert !@guest.may_divide?(10, 2)
      assert @student.may_divide?(10, 2)
      assert !@student.may_divide?(10, 0)
      assert @admin.may_divide?(10, 2)
      assert @admin.may_divide?(10, 0)
    end
    
    should 'use default permissions for undefined actions' do
      !@student.may_do_undefined_stuff?("foo")
      @admin.may_do_undefined_stuff?("foo")
    end
    
    should 'overshadow previous action definitions with the same name' do
      assert @guest.may_draw?
      assert !@student.may_draw?
      assert !@admin.may_draw?
    end
    
  end

end
