module Aegis
  module Controller

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
    end

    module ClassMethods

      private

      def require_permissions(options = {})
        before_filter :unchecked_permissions, options
      end

      def skip_permissions(options = {})
        skip_before_filter :unchecked_permissions, options
      end

      def permissions(resource, options = {})

        filter_options = options.slice(:except, :only)

        skip_before_filter :unchecked_permissions, filter_options

        # Store arguments for testing
        @aegis_permissions_resource = resource
        @aegis_permissions_options = options

        before_filter :check_permissions, filter_options

        instance_eval do

          private

          actions_map = (options[:map] || {}).stringify_keys
          object_method = options[:object] || :object
          parent_object_method = options[:parent_object] || :parent_object
          user_method = options[:user] || :current_user
          permissions = lambda { Aegis::Permissions.app_permissions(options[:permissions]) }

          define_method :check_permissions do
            action = permissions.call.guess_action(
              resource,
              action_name.to_s,
              actions_map
            )
            args = []
            args << send(user_method)
            args << send(parent_object_method) if action.takes_parent_object
            args << send(object_method) if action.takes_object
            action.may!(*args)
          end

        end

      end

    end

    module InstanceMethods

      private

      def unchecked_permissions
        raise Aegis::UncheckedPermissions, "This controller does not check permissions"
      end

    end

  end
end

