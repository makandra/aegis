require "spec_helper"

describe Aegis::Controller do

  before(:each) do

    permissions_class = @permissions_class = Class.new(Aegis::Permissions) do
      role :user
      resources :posts do
        reading do
          allow :user
        end
      end
    end

    @user_class = Class.new(ActiveRecord::Base) do
      set_table_name 'users'
      has_role :permissions => permissions_class
    end

    user = @user = @user_class.new(:role_name => 'user')

    @controller_class = Class.new(ActionController::Base) do
      include Aegis::Controller
      define_method :current_user do
        user
      end
    end

  end

  describe 'require_permissions' do

    it "should set a before_filter :unchecked_permissions" do
      @controller_class.should_receive(:before_filter).with(:unchecked_permissions, :only => :show)
      @controller_class.class_eval do
        require_permissions :only => :show
      end
    end

  end

  describe 'skip_permissions' do

    it "should skip a before_filter :unchecked_permissions" do
      @controller_class.should_receive(:skip_before_filter).with(:unchecked_permissions, :only => :show)
      @controller_class.class_eval do
        skip_permissions :only => :show
      end
    end

  end

  describe 'unchecked_permissions' do

    it "should raise Aegis::UncheckedPermissions" do
      controller = @controller_class.new
      expect { controller.send(:unchecked_permissions) }.to raise_error(Aegis::UncheckedPermissions)
    end

  end

  describe 'permissions' do

    it "should fetch the context through #object, #parent_object and #current_user by default" do
      permissions_class = @permissions_class
      @controller_class.class_eval do
        permissions :posts, :permissions => permissions_class
      end
      controller = @controller_class.new
      permissions_class.stub(:guess_action => stub('action', :takes_object => true, :takes_parent_object => true).as_null_object)
      controller.should_receive(:object).and_return('the object')
      controller.should_receive(:parent_object).and_return('the parent object')
      controller.should_receive(:current_user).and_return('the user')
      controller.send(:check_permissions)
    end

    it "should allow custom readers for object, parent object and the current user" do
      permissions_class = @permissions_class
      @controller_class.class_eval do
        permissions :posts, :permissions => permissions_class, :user => :my_user, :object => :my_object, :parent_object => :my_parent 
      end
      controller = @controller_class.new
      permissions_class.stub(:guess_action => stub('action', :takes_object => true, :takes_parent_object => true).as_null_object)
      controller.should_receive(:my_object).and_return('the object')
      controller.should_receive(:my_parent).and_return('the parent object')
      controller.should_receive(:my_user).and_return('the user')
      controller.send(:check_permissions)
    end

    it 'should install a before_filter that checks permissions' do
      @controller_class.should_receive(:before_filter).with(:check_permissions, :only => [:update])
      permissions_class = @permissions_class
      @controller_class.class_eval do
        permissions :posts, :permissions => permissions_class, :only => [:update]
      end
    end

  end

  describe 'check_permissions' do

    before(:each) do
      permissions_class = @permissions_class
      map = @map = { 'controller_action' => 'permission_path' }
      @controller_class.class_eval do
        permissions :posts, :permissions => permissions_class, :map => map
      end
      @controller = @controller_class.new
      @controller.stub(:object => "object", :parent_object => "parent object")
    end

    it "should guess the aegis-action using the current resource, action name and actions-map" do
      @controller.stub(:action_name => 'update')
      action = stub("action").as_null_object
      @permissions_class.should_receive(:guess_action).with(:posts, 'update', @map).and_return(action)
      @controller.send(:check_permissions)
    end

    it "should raise an error if permission is denied" do
      @controller.stub(:action_name => 'update')
      lambda { @controller.send(:check_permissions) }.should raise_error(Aegis::AccessDenied)
    end

    it "should pass silently if permission is granted" do
      @controller.stub(:action_name => 'show')
      lambda { @controller.send(:check_permissions) }.should_not raise_error
    end

  end

end
