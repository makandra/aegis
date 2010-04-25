module Aegis
  class Permissions
    class << self

      def action(*args, &block)
        prepare
        @parser.action(*args, &block)
      end

      def resource(*args, &block)
        prepare
        @parser.resource(*args, &block)
      end

      def namespace(*args, &block)
        prepare
        @parser.namespace(*args, &block)
      end

      def resources(*args, &block)
        prepare
        @parser.resources(*args, &block)
      end

      def may?(user, path, *args)
        find_action_by_path(path).may?(user, *args)
      end

      def may!(user, path, *args)
        find_action_by_path(path).may!(user, *args)
      end

      def role(role_name, options = {})
        role_name = role_name.to_s
        role_name != 'everyone' or raise "Cannot define a role named: #{role_name}"
        @roles_by_name ||= {}
        @roles_by_name[role_name] = Aegis::Role.new(role_name, self, options)
      end

      def roles
        @roles_by_name.values.sort
      end

      def find_role_by_name(name)
        @roles_by_name[name.to_s]
      end

      def guess_action(resource, action_name, map)
        action = nil
        guess_action_paths(resource, action_name, map).detect do |path|
          action = find_action_by_path(path)
        end
        action
      end

      def guess_action!(resource, action_name, map)
        guess_action(resource, action_name, map) or raise "Undefined permission: #{resource}##{action_name}"
      end

      def find_action_by_path(path)
        compile
        @actions_by_path[path.to_s] || Aegis::Action.undefined
      end

      def app_permissions(option)
        if option.is_a?(Class)
          option
        else
          (option || '::Permissions').constantize
        end
      end

      def inspect
        compile
        "Permissions(#{@root_resource.inspect})"
      end

      private

      def guess_action_paths(resource, action_name, map)
        if mapped = map[action_name]
          [ mapped.singularize,
            mapped.pluralize ]
        else
          [ "#{action_name}_#{resource.singularize}",
            "#{action_name}_#{resource.pluralize}" ]
        end
      end

      def prepare
        unless @parser
          @parser = Aegis::Parser.new
        end
      end

      def compile
        unless @root_resource
          prepare
          @root_resource = Aegis::Resource.new(nil, nil, :root, {})
          Aegis::Compiler.compile(@root_resource, @parser.atoms)
          @actions_by_path = @root_resource.index_actions_by_path
        end
      end

    end
  end
end
