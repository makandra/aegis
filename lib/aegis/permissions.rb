module Aegis
  class Permissions
    class << self

      MISSING_ACTION_STRATEGIES = [
        :allow, :deny, :default_permission, :error
      ]

      def missing_action_means(strategy)
        prepare
        MISSING_ACTION_STRATEGIES.include?(strategy) or raise ArgumentError, "missing_action_means must be one of #{MISSING_ACTION_STRATEGIES.inspect}"
        @missing_action_strategy = strategy
      end

      def missing_user_means(&strategy)
        prepare
        @missing_user_strategy = strategy
      end

      def alias_action(aliases)
        prepare
        aliases.each do |key, value|
          @action_aliases[key.to_s] = value.to_s
        end
      end

      def permission(*args)
        raise "The Aegis API has changed. See http://wiki.github.com/makandra/aegis/upgrading-to-aegis-2 for migration instructions."
      end

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
        query_action(:may?, user, path, *args)
      end

      def may!(user, path, *args)
        query_action(:may!, user, path, *args)
      end

      def role(role_name, options = {})
        role_name = role_name.to_s
        role_name != 'everyone' or raise "Cannot define a role named: #{role_name}"
        @roles_by_name ||= {}
        @roles_by_name[role_name] = Aegis::Role.new(role_name, options)
      end

      def roles
        @roles_by_name.values.sort
      end

      def find_role_by_name(name)
        @roles_by_name[name.to_s]
      end

      def guess_action(resource_name, action_name, map = {})
        compile
        action = nil
        action_name = action_name.to_s
        guess_action_paths(resource_name, action_name, map).detect do |path|
          action = find_action_by_path(path, false)
        end
        handle_missing_action(action)
      end

      def find_action_by_path(path, handle_missing = true)
        compile
        action = @actions_by_path[path.to_s]
        action = handle_missing_action(action) if handle_missing
        action
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

      def query_action(verb, user, path, *args)
        user = handle_missing_user(user)
        action = find_action_by_path(path)
        action.send(verb, user, *args)
      end

      def handle_missing_user(possibly_missing_user)
        possibly_missing_user ||= case @missing_user_strategy
          when :error then raise "Cannot check permission without a user"
          when Proc then @missing_user_strategy.call
        end
      end

      def handle_missing_action(possibly_missing_action)
        possibly_missing_action ||= case @missing_action_strategy
          when :default_permission then Aegis::Action.undefined
          when :allow then Aegis::Action.allow_to_all
          when :deny then Aegis::Action.deny_to_all
          when :error then raise "Undefined Aegis action: #{action}"
        end
      end

      def guess_action_paths(resource_name, action_name, map)
        if mapped = map[action_name]
          [ mapped.to_s ]
        else
          [ "#{action_name}_#{resource_name.to_s.singularize}",
            "#{action_name}_#{resource_name.to_s.pluralize}",
            resource_name ]
        end
      end

      def prepare
        unless @parser
          @parser = Aegis::Parser.new
          @missing_user_strategy = :error
          @missing_action_strategy = :default_permission
          @action_aliases = {
            'new' => 'create',
            'edit' => 'update'
          }
        end
      end

      def compile
        unless @root_resource
          prepare
          @root_resource = Aegis::Resource.new(nil, nil, :root, {})
          Aegis::Compiler.compile(@root_resource, @parser.atoms)
          index_actions
        end
      end

      def index_actions
        @actions_by_path = @root_resource.index_actions_by_path(@action_aliases)        
      end

    end
  end
end
