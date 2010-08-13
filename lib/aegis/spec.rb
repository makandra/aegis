module Aegis
  module Matchers

    class CheckPermissions

      def initialize(expected_resource, expected_options = {})
        @expected_resource = expected_resource
        @expected_options = expected_options
      end

      def matches?(controller)
        @controller_class = controller.class
        @actual_resource = @controller_class.instance_variable_get('@aegis_permissions_resource')
        @actual_options = @controller_class.instance_variable_get('@aegis_permissions_options')
        @actual_resource == @expected_resource && @actual_options == @expected_options
      end

      def failure_message
        if @actual_resource != @expected_resource
          "expected #{@controller_class} to check permissions against resource #{@expected_resource.inspect}, but it checked against #{@actual_resource.inspect}"
        else
          "expected #{@controller_class} to check permissions with options #{@expected_options.inspect}, but options were #{@actual_options.inspect}"
        end
      end

      def negative_failure_message
        if @actual_resource == @expected_resource
          "expected #{@controller_class} to not check permissions against resource #{@expected_resource.inspect}"
        else
          "expected #{@controller_class} to not check permissions with options #{@expected_options.inspect}"
        end
      end

      def description
        description = "check permissions against resource #{@expected_resource.inspect}"
        description << " with options #{@expected_options.inspect}" if @expected_options.any?
        description
      end

    end

    def check_permissions(*args)
      CheckPermissions.new(*args)
    end

  end
end


ActiveSupport::TestCase.send :include, Aegis::Matchers

#Spec::Rails::Example::ControllerExampleGroup.extend Aegis::ControllerSpecMacros


#  def it_should_allow_access_for(*allowed_roles, &block)
#
#    denied_roles = Permissions.roles.collect(&:name) - allowed_roles
#
#    describe 'permissions' do
#
#      before :each do
#        sign_out
#      end
#
#      it "should deny access when no user is signed in" do
#        expect { instance_eval(&block) }.to raise_error(Aegis::AccessDenied)
#      end
#
#      allowed_roles.each do |role|
#        it "should allow access for an authenticated #{role}" do
#          sign_in User.new(:role_name => role)
#          expect { instance_eval(&block) }.to_not raise_error
#          response.code.should == '200'
#        end
#      end
#
#      denied_roles.each do |role|
#        it "should deny access for an authenticated #{role}" do
#          sign_in User.new(:role_name => role)
#          expect { instance_eval(&block) }.to raise_error(Aegis::AccessDenied)
#        end
#      end
#
#    end
#
#  end
