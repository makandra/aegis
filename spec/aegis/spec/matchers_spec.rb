require 'spec_helper'

describe Aegis::Spec::Matchers do

  describe 'be_allowed_to' do

    before(:each) do

      permissions = @permissions = Class.new(Aegis::Permissions) do
        role :user
        resources :files do
          allow :user do
            object == 'allowed-file'
          end
        end
      end

      @user_class = Class.new(ActiveRecord::Base) do
        set_table_name 'users'
        has_role :permissions => permissions
      end

      @user = @user_class.new(:role_name => 'user')

    end

    it 'should match the positive case' do
      @user.should be_allowed_to(:update_file, 'allowed-file')
    end

    it 'should match the negative case' do
      @user.should_not be_allowed_to(:update_file, 'denied-file')
    end

  end

  describe 'check_permissions' do

    before(:each) do
      @controller = Class.new(ActionController::Base) do
        permissions :post
      end.new
    end

    it 'should match the positive case' do
      @controller.should check_permissions(:post)
    end

    it 'should match the negative case' do
      @controller.should_not check_permissions(:reviews)
    end

  end

end
