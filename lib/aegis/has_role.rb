module Aegis
  module HasRole

    def has_role(options = {})

      permissions = lambda { Aegis::Permissions.app_permissions(options[:permissions]) }

      may_pattern = /^may_(.+?)([\!\?])$/

      send :define_method, :role_names do
        (role_name || '').split(/\s*,\s*/)
      end

      send :define_method, :role_names= do |role_names|
        self.role_name = role_names.reject(&:blank?).join(',')
      end

      send :define_method, :role do
        roles.first
      end

      send :define_method, :roles do
        role_names.collect do |role_name|
          permissions.call.find_role_by_name(role_name)
        end.compact
      end

      send :define_method, :has_role? do |role_name|
        role_names.include?(role_name.to_s)
      end

      metaclass ||= singleton_class
      metaclass.send :define_method, :validates_role do |*validate_options|
        validate_options = validate_options[0] || {}

        send :define_method, :validate_role do
          unless role_names.size > 0 && role_names.size == roles.size
            message = validate_options[:message] || I18n.translate('activerecord.errors.messages.inclusion')
            errors.add :role_name, message
          end
        end

        validate :validate_role
      end

      if options[:default]

        unless method_defined?(:after_initialize)
          send :define_method, :after_initialize do
          end
        end

        send :define_method, :set_default_role_name do
          if new_record? && role_name.blank?
            self.role_name = options[:default]
          end
        end

        after_initialize :set_default_role_name

      end

      unless method_defined?(:method_missing_with_aegis_permissions)

        # Delegate may_...? and may_...! methods to the permissions class.
        send :define_method, :method_missing_with_aegis_permissions do |symb, *args|
          method_name = symb.to_s
          if method_name =~ may_pattern
            action_path = $1
            severity = $2
            permissions.call.send("may#{severity}", self, action_path, *args)
          else
            method_missing_without_aegis_permissions(symb, *args)
          end
        end

        alias_method_chain :method_missing, :aegis_permissions

        send :define_method, :respond_to_with_aegis_permissions? do |symb, *args|
          if symb.to_s =~ may_pattern
            true
          else
            include_private = args.first.nil? ? false : args.first
            respond_to_without_aegis_permissions?(symb, include_private)
          end
        end

        alias_method_chain :respond_to?, :aegis_permissions

      end
    end

  end
end
