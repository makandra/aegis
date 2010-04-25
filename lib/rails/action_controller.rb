module Aegis
  module ActionController

    def permissions(resource, options = {})

      before_filter :check_permissions

      instance_eval do

        private

        actions_map = (options[:actions] || {}).stringify_keys
        object_method = options[:object] || :object
        parent_object_method = options[:parent_object] || :parent_object
        current_user_method = options[:current_user] || :current_user
        permissions = lambda { Aegis::Permissions.app_permissions(options[:permissions]) }

        define_method :check_permissions do
          action = permissions.call.guess_action!(
            resource,
            action_name.to_s,
            actions_map
          )
          args = []
          args << send(current_user_method)
          args << send(parent_object_method) if action.takes_parent_object?
          args << send(object_method) if action.takes_object?
          action.may!(*args)
        end

      end

    end

  end
end

ActionController::Base.extend(Aegis::ActionController)
