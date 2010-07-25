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
      user.should respond_to(:roles)
    end

    it "should allow a default for new records" do
      permissions_class = @permissions_class
      @user_class.class_eval { has_role :permissions => permissions_class, :default => "admin" }
      user = @user_class.new
      user.role_name.should == 'admin'
    end

  end

  describe 'role' do

    it "should return the first role" do
      user = @user_class.new
      user.should_receive(:roles).and_return(['first role', 'second role'])
      user.role.should == 'first role'
    end

    it "should be nil if no roles are associated" do
      user = @user_class.new
      user.should_receive(:roles).and_return([])
      user.role.should be_nil
    end

  end

  describe 'roles' do

    it "should return the corresponding role for each role name" do
      user = @user_class.new
      user.should_receive(:role_names).and_return(['admin', 'user'])
      user.roles.collect(&:name).should == ['admin', 'user']
    end

    it "should ignore unknown role names that doesn't match a known role" do
      user = @user_class.new
      user.should_receive(:role_names).and_return(['unknown role', 'user'])
      user.roles.collect(&:name).should == ['user']
    end

  end

  describe 'role_names' do

    it "should be empty if the role name is blank" do
      user = @user_class.new(:role_name => '')
      user.role_names.should be_empty
    end

    it "should be empty if the role_name is nil" do
      user = @user_class.new(:role_name => nil)
      user.role_names.should be_empty
    end

    it "should deserialize a single role name into an array with a single element" do
      user = @user_class.new(:role_name => 'admin')
      user.role_names.should == ['admin']
    end

    it "should deserialize multiple, comma-separated role names into an array" do
      user = @user_class.new(:role_name => 'admin,user')
      user.role_names.should == ['admin', 'user']
    end

    it "should ignore whitespace around the comma-separator" do
      user = @user_class.new(:role_name => 'admin , user')
      user.role_names.should == ['admin', 'user']
    end
    
  end

  describe 'role_names=' do

    it "should serialize the given array into a comma-separated string and store it into #role_name" do
      user = @user_class.new
      user.should_receive(:role_name=).with("first,second")
      user.role_names = ['first', 'second']
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

    it "should add an inclusion error to the role name if the role name is nil" do
      user = @user_class.new(:role_name => nil)
      user.errors.should_receive(:add).with(:role_name, I18n.translate('activerecord.errors.messages.inclusion'))
      user.send(:validate_role)
    end

    it "should add an inclusion error to the role name if the role name is an empty string" do
      user = @user_class.new(:role_name => '')
      user.errors.should_receive(:add).with(:role_name, I18n.translate('activerecord.errors.messages.inclusion'))
      user.send(:validate_role)
    end

    it "should add an inclusion error to the role name if a role name doesn't match a role" do
      user = @user_class.new(:role_name => 'user,nonexisting_role')
      user.errors.should_receive(:add).with(:role_name, I18n.translate('activerecord.errors.messages.inclusion'))
      user.send(:validate_role)
    end

    it "should add no error if all role names matches a role" do
      user = @user_class.new(:role_name => 'admin,user')
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
