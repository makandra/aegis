require File.dirname(__FILE__) + "/spec_helper"

describe Aegis::Permissions do

  before(:each) do

    permissions = @permissions = Class.new(Aegis::Permissions) do
      role :user
      role :moderator
      role :admin, :default_permission => :allow
    end

    @user_class = Class.new(ActiveRecord::Base) do
      set_table_name 'users'
      has_role :permissions => permissions
    end

    @user = @user_class.new(:role_name => 'user')
    @moderator = @user_class.new(:role_name => 'moderator')
    @admin = @user_class.new(:role_name => 'admin')

  end
  
  describe 'find_role_by_name' do

    it "should look up previously defined roles" do

      user_role = @permissions.find_role_by_name('user')
      admin_role = @permissions.find_role_by_name('admin')

      user_role.name.should == 'user'
      user_role.may_by_default?.should be_false

      admin_role.name.should == 'admin'
      admin_role.may_by_default?.should be_true

    end

    it "should be nil if no role with that name was defined" do
      @permissions.find_role_by_name('nonexisting_role').should be_nil
    end

  end

  describe 'may?' do

    it "should evaluate previously defined actions" do

      @permissions.class_eval do
        action :action_name do
          allow
        end
      end

      @permissions.may?(@user, 'action_name').should be_true
      @permissions.may?(@admin, 'action_name').should be_true

    end

    it "should return the default permission when queried for undefined actions" do

      @permissions.may?(@user, 'undefined_action').should be_false
      @permissions.may?(@admin, 'undefined_action').should be_true

    end

    it "should distinguish between roles" do

      @permissions.class_eval do
        action :update_news do
          allow :moderator
        end
      end

      @permissions.may?(@user, 'update_news').should be_false
      @permissions.may?(@moderator, 'update_news').should be_true

    end

    it "should run sieves in a sequence, the result being the last matching sieve" do

      @permissions.class_eval do
        action :update_news do
          allow :everyone
          deny :user
        end
      end

      @permissions.may?(@user, 'update_news').should be_false
      @permissions.may?(@moderator, 'update_news').should be_true

    end

    it "should evaluate collection resources" do

      @permissions.class_eval do
        resources :posts do
          allow :moderator
        end
      end

      #p @permissions
      #p @permissions.instance_variable_get("@actions_by_path").keys

      @permissions.may?(@moderator, 'update_post', "the post").should be_true
      @permissions.may?(@moderator, 'show_post', "the post").should be_true
      @permissions.may?(@moderator, 'create_post', "the post").should be_true
      @permissions.may?(@moderator, 'destroy_post', "the post").should be_true
      @permissions.may?(@moderator, 'index_posts').should be_true

    end

    it "should raise an error if an action takes an object but does not get it in the arguments" do

      @permissions.class_eval do
        resources :posts do
          allow :moderator
        end
      end

      @permissions.may?(@moderator, 'update_post', "the post").should be_true

    end

    it "should evaluate sieves with blocks" do

      @permissions.class_eval do
        resources :posts do
          allow :user do
            user.name == 'Waldo'
          end
        end
      end

      frank = @user_class.new(:name => 'Frank', :role_name => 'user')
      waldo = @user_class.new(:name => 'Waldo', :role_name => 'user')

      frank.may_update_post?('the post').should be_false
      waldo.may_update_post?('the post').should be_true

    end

    it "should evaluate singleton resources, which take no object" do

      @permissions.class_eval do
        resource :session do
          allow :moderator
        end
      end

      @permissions.may?(@moderator, 'update_session').should be_true
      @permissions.may?(@moderator, 'show_session').should be_true
      @permissions.may?(@moderator, 'create_session').should be_true
      @permissions.may?(@moderator, 'destroy_session').should be_true

    end

    it "should allow to nest resources into collection resources" do

      @permissions.class_eval do
        resources :properties do
          resources :comments do
            allow :moderator
          end
        end
      end

      @permissions.may?(@moderator, 'update_property_comment', "the property", "the comment").should be_true
      @permissions.may?(@moderator, 'show_property_comment', "the property", "the comment").should be_true
      @permissions.may?(@moderator, 'create_property_comment', "the property").should be_true
      @permissions.may?(@moderator, 'destroy_property_comment', "the property", "the comment").should be_true
      @permissions.may?(@moderator, 'index_property_comments', "the property").should be_true

    end

    it "should allow to nest resources into singleton resources" do

      @permissions.class_eval do
        resource :account do
          resources :bookings do
            allow :moderator
          end
        end
      end

      @permissions.may?(@moderator, 'update_account_booking', "the booking").should be_true
      @permissions.may?(@moderator, 'show_account_booking', "the booking").should be_true
      @permissions.may?(@moderator, 'create_account_booking').should be_true
      @permissions.may?(@moderator, 'destroy_account_booking', "the booking").should be_true
      @permissions.may?(@moderator, 'index_account_bookings').should be_true

      @permissions.find_action_by_path('update_account').should be_abstract

    end

    it "should support namespaces, which act like singleton resources but don't generate actions by default" do

      @permissions.class_eval do
        namespace :admin do
          resources :bookings do
            allow :moderator
          end
        end
      end

      @permissions.may?(@moderator, 'update_admin_booking', "the booking").should be_true
      @permissions.may?(@moderator, 'show_admin_booking', "the booking").should be_true
      @permissions.may?(@moderator, 'create_admin_booking').should be_true
      @permissions.may?(@moderator, 'destroy_admin_booking', "the booking").should be_true
      @permissions.may?(@moderator, 'index_admin_bookings').should be_true

      @permissions.find_action_by_path('update_admin').should_not be_abstract

    end

    it "should allow multiple levels of resource-nesting" do

      @permissions.class_eval do
        resources :properties do
          resources :reviews do
            resources :comments do
              allow :moderator
            end
          end
        end
      end

      @permissions.may?(@moderator, 'update_property_review_comment', "the review", "the comment").should be_true
      @permissions.may?(@moderator, 'show_property_review_comment', "the review", "the comment").should be_true
      @permissions.may?(@moderator, 'create_property_review_comment', "the review").should be_true
      @permissions.may?(@moderator, 'destroy_property_review_comment', "the review", "the comment").should be_true
      @permissions.may?(@moderator, 'index_property_review_comments', "the review").should be_true
      
    end

    it "should raise an error if an action takes a parent object but does not get it in the arguments" do

      @permissions.class_eval do
        resources :properties do
          resources :comments
        end
      end

      lambda { @permissions.may?(@moderator, 'update_property_comment', "the comment") }.should raise_error(ArgumentError)

    end

    it "should allow sieves with blocks and arguments" do

      @permissions.class_eval do
        action :sign_in do
          allow do |password|
            user.password == password
          end
        end
      end

      @user.stub(:password => "secret")
      @user.may_sign_in?("wrong_password").should be_false
      @user.may_sign_in?("secret").should be_true

    end

    it "should provide the object and parent_object for a sieve block" do
      spy = stub("spy")
      @permissions.class_eval do
        resources :properties do
          resources :comments do
            allow :moderator do |additional_argument|
              spy.observe(parent_object, object, additional_argument)
            end
          end
        end
      end

      spy.should_receive(:observe).with("the property", "the comment", "additional argument")
      @moderator.may_update_property_comment?("the property", "the comment", "additional argument")
    end

    it "should evaluate additional resource actions" do

      @permissions.class_eval do
        resources :properties do
          action :zoom_into do
            allow :user
          end
          action :view_all, :collection => true do
            allow :user
          end
        end
      end

      @permissions.may?(@user, "zoom_into_property", "the property").should be_true
      @permissions.may?(@user, "view_all_properties", "the property").should be_true

    end

    it "should allow rules that only affect reading actions" do

      @permissions.class_eval do
        resources :posts do
          reading do
            allow :user
          end
          action :syndicate, :writing => false
          action :close
        end
      end

      @permissions.may?(@user, 'update_post', "the post").should be_false
      @permissions.may?(@user, 'show_post', "the post").should be_true
      @permissions.may?(@user, 'create_post', "the post").should be_false
      @permissions.may?(@user, 'destroy_post', "the post").should be_false
      @permissions.may?(@user, 'index_posts').should be_true
      @permissions.may?(@user, 'syndicate_post', "the post").should be_true
      @permissions.may?(@user, 'close_post", "the post').should be_false

    end

    it "should allow rules that only affect writing actions" do

      @permissions.class_eval do
        resources :posts do
          writing do
            allow :moderator
          end
          action :syndicate, :writing => false
          action :close
        end
      end

      # debugger

      @permissions.may?(@moderator, 'update_post', "the post").should be_true
      @permissions.may?(@moderator, 'show_post', "the post").should be_false
      @permissions.may?(@moderator, 'create_post', "the post").should be_true
      @permissions.may?(@moderator, 'destroy_post', "the post").should be_true
      @permissions.may?(@moderator, 'index_posts').should be_false
      @permissions.may?(@moderator, 'syndicate_post', "the post").should be_false
      @permissions.may?(@moderator, "close_post", "the post").should be_true

    end

    it "should allow resources with only selected actions" do
      @permissions.class_eval do
        resources :posts, :only => [:show, :update]
      end
      @permissions.find_action_by_path('update_post').should be_abstract
      @permissions.find_action_by_path('show_post').should be_abstract
      @permissions.find_action_by_path('create_post').should_not be_abstract
      @permissions.find_action_by_path('destroy_post').should_not be_abstract
      @permissions.find_action_by_path('index_posts').should_not be_abstract
    end

    it "should allow resources with all actions except a selected few" do
      @permissions.class_eval do
        resources :posts, :except => [:show, :update]
      end
      @permissions.find_action_by_path('update_post').should_not be_abstract
      @permissions.find_action_by_path('show_post').should_not be_abstract
      @permissions.find_action_by_path('create_post').should be_abstract
      @permissions.find_action_by_path('destroy_post').should be_abstract
      @permissions.find_action_by_path('index_posts').should be_abstract
    end

  end

  describe 'may!' do

    it "should return if permission is granted" do
      lambda { @permissions.may!(@admin, :delete_everything) }.should_not raise_error
    end

    it "should raise an error if permission is denied" do
      lambda { @permissions.may!(@user, :delete_everything) }.should raise_error(Aegis::AccessDenied)
    end

  end

  describe 'handle_undefined_action' do

    it "should use the default permission if the strategy is :default_permission" do
      @permissions.class_eval do
        missing_action_means :default_permission
      end
      @user.may_undefined_action?.should be_false
      @admin.may_undefined_action?.should be_true
    end

    it "should grant everyone access if the strategy is :allow" do
      @permissions.class_eval do
        missing_action_means :allow
      end
      @user.may_undefined_action?.should be_true
      @admin.may_undefined_action?.should be_true
    end

    it "should deny everyone access if the strategy is :deny" do
      @permissions.class_eval do
        missing_action_means :deny
      end
      @user.may_undefined_action?.should be_false
      @admin.may_undefined_action?.should be_false
    end

    it "should raise an error if the strategy is :error" do
      @permissions.class_eval do
        missing_action_means :error
      end
      lambda { @user.may_undefined_action? }.should raise_error
      lambda { @admin.may_undefined_action? }.should raise_error
    end

  end

end

