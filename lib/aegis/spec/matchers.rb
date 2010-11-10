module Aegis
  module Spec
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

      class BeAllowedTo

        def initialize(expected_action, *expected_args)
          @expected_action = expected_action
          @expected_args = expected_args
        end

        def matches?(user)
          @actual_user = user
          @actual_user.send("may_#{@expected_action}?", *@expected_args)
        end

        def description
          "be allowed to #{action_as_prose}"
        end

        def failure_message
          "expected #{@actual_user.inspect} to be allowed to #{action_as_prose}"
        end

        def negative_failure_message
          "expected #{@actual_user.inspect} to be denied to #{action_as_prose}"
        end

        private

        def action_as_prose
          @expected_action.to_s + (@expected_args.present? ? " given #{@expected_args.inspect}" : "")
        end

      end

      def be_allowed_to(*args)
        BeAllowedTo.new(*args)
      end

    end
  end
end

ActiveSupport::TestCase.send :include, Aegis::Spec::Matchers

