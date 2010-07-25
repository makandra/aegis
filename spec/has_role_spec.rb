require File.dirname(__FILE__) + "/spec_helper"

describe Aegis::HasRole do

  before(:each) do

    @permissions_class = permissions_class = Class.new(Aegis::Permissions) do
      role :user
      role :admin
    end

    @user_class = Class.new(ActiveRecord::Base) do
      set_table_name 'users'
      has_role :permissions => permissions_class
    end

  end

  describe 'has_role' do

    it "should define accessors for the role association" do
      user = @user_class.new
      user.should respond_to(:role)
      user.should respond_to(:role=)
    end

  end

  describe 'role' do

    it "should be nil by default" do
      user = @user_class.new
      user.role.should be_nil
    end

    it "should return the role corresponding to the role_name" do
      user = @user_class.new(:role_name => 'admin')
      user.role.name.should == 'admin'
    end

    it "should be nil if the role_name doesn't match a known role" do
      user = @user_class.new(:role_name => 'nonexisting_role_name')
      user.role.should be_nil
    end

    it "should take a default role" do
      permissions_class = @permissions_class
      @user_class.class_eval { has_role :default => "admin", :permissions => permissions_class }
      user = @user_class.new
      user.role.name.should == 'admin'
    end

  end

  describe 'role=' do

    before :each do
      @admin_role = @permissions_class.find_role_by_name('admin')
    end

    it "should write the role name to the role_name attribute" do
      user = @user_class.new
      user.should_receive(:role_name=).with('admin')
      user.role = @admin_role
    end

  end

  describe 'method_missing' do

    it "should delegate may...? messages to the permissions class" do
      user = @user_class.new
      @permissions_class.should_receive(:may?).with(user, 'do_action', 'argument')
      user.may_do_action?('argument')
    end

    it "should delegate may...! messages to the permissions class" do
      user = @user_class.new
      @permissions_class.should_receive(:may!).with(user, 'do_action', 'argument')
      user.may_do_action!('argument')
    end

    it "should retain its usual behaviour for non-permission methods" do
      user = @user_class.new
      lambda { user.nonexisting_method }.should raise_error(NoMethodError)
    end

  end

  describe 'respond_to?' do

    it "should be true for all permission methods, even if they are not explicitely defined" do
      user = @user_class.new
      user.should respond_to(:may_foo?)
      user.should respond_to(:may_foo!)
    end

    it "should retain its usual behaviour for non-permission methods" do
      user = @user_class.new
      user.should respond_to(:to_s)
      user.should_not respond_to(:nonexisting_method)
    end

  end

  describe 'validates_role' do

    before(:each) do
      @user_class.class_eval { validates_role }
    end

    it "should run the validation callback :validate_role" do
      user = @user_class.new
      user.should_receive(:validate_role)
      user.run_callbacks(:validate)
    end

    it "should add an inclusion error to the role name if the role name is blank" do
      user = @user_class.new(:role_name => '')
      user.errors.should_receive(:add).with(:role_name, I18n.translate('activerecord.errors.messages.inclusion'))
      user.send(:validate_role)
    end

    it "should add an inclusion error to the role name if the role name doesn't match a role" do
      user = @user_class.new(:role_name => 'nonexisting_role')
      user.errors.should_receive(:add).with(:role_name, I18n.translate('activerecord.errors.messages.inclusion'))
      user.send(:validate_role)
    end

    it "should add no error if the role name matches a role" do
      user = @user_class.new(:role_name => 'admin')
      user.errors.should_not_receive(:add)
      user.send(:validate_role)
    end

    it "should allow a custom error message with the :message options" do
      @user_class.class_eval { validates_role :message => "custom message" }
      user = @user_class.new(:role_name => '')
      user.errors.should_receive(:add).with(:role_name, 'custom message')
      user.send(:validate_role)
    end

  end

end
