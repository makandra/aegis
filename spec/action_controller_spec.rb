require File.dirname(__FILE__) + "/spec_helper"

describe 'Aegis::ActionController' do

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
      define_method :current_user do
        user
      end
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
      controller.should_receive(:object)
      controller.should_receive(:parent_object)
      controller.should_receive(:current_user)
      controller.send(:check_permissions)
    end

    it "should allow custom readers for object, parent object and the current user" do
      permissions_class = @permissions_class
      @controller_class.class_eval do
        permissions :posts, :permissions => permissions_class, :user => :my_user, :object => :my_object, :parent_object => :my_parent 
      end
      controller = @controller_class.new
      permissions_class.stub(:guess_action => stub('action', :takes_object => true, :takes_parent_object => true).as_null_object)
      controller.should_receive(:my_object)
      controller.should_receive(:my_parent)
      controller.should_receive(:my_user)
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
