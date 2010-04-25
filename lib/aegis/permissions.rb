module Aegis
  class Permissions
    class << self
      attr_accessor :root_resource

      def action(*args, &block)
        prepare
        parser.action(*args, &block)
      end

      def resource(name, options, &block)
        prepare
        parser.resource(*args, &block)
      end

      def resources(name, options, &block)
        prepare
        parser.resources(*args, &block)
      end

      def may?(user, path, *args)
        find_action_by_path!(path).may?(user, *args)
      end

      def may!(user, path, *args)
        find_action_by_path!(path).may!(user, *args)
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

      def find_role_by_name!(name)
        find_role_by_name(name) or raise "Undefined role: #{name}"
      end

      def guess_action(resource, action_name)
        paths = [
          "#{action_name}_#{resource}",
          "#{action_name}_#{resource.singularize}",
          "#{action_name}_#{resource.pluralize}"
        ]
      end

      def guess_action!(resource, action_name)
        guess_action(resource, action_name) or raise "Undefined permission: #{resource}##{action_name}"
      end

      def find_action_by_path(path)
        compile
        @actions_by_path[path.to_s]
      end

      def find_action_by_path!(path)
        compile
        find_action_by_path(path) or raise "Undefined permission: #{path}"
      end

      def definition_class(option)
        if option.is_a?(Class)
          option
        else
          (option || '::Permissions').constantize
        end
      end

      private

      def prepare
        unless self.parser
          self.parser = Aegis::Parser.new
        end
      end

      def compile
        unless self.root_resource
          root_resource = Resource.new(nil, nil, :root, {})
          Compiler.compile(root_resource, parser.atoms)
          @actions_by_path = root_resource.index_actions_by_path
        end
      end

    end
  end
end
