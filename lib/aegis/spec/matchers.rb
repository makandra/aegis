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

      def be_allowed_to(*args)
        simple_matcher do |user, matcher|
          action, *action_args = args
          target = action.to_s + (action_args.present? ? " given #{action_args.inspect}" : "")
          matcher.description = "be allowed to " + target
          matcher.failure_message = "expected #{user.inspect} to be allowed to #{target}"
          matcher.negative_failure_message = "expected #{user.inspect} to be denied to #{target}"
          user.send("may_#{action}?", *action_args)
        end
      end

    end
  end
end

ActiveSupport::TestCase.send :include, Aegis::Spec::Matchers

