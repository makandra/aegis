module Aegis
  class Permissions
  
    def self.inherited(base)
      base.class_eval do
        extend ClassMethods
      end
    end    

    module ClassMethods
    
      @@roles_by_name = {}
      @@permission_blocks = {}  # @@permission_blocks[:update_users] = [lambda { allow :admin; deny :guest }, lambda { deny :student }]
      @@permission_block_mutex = Mutex.new
      @@permission_block_result = nil
      @@permission_block_role_name = nil

      EVERYONE_ROLE_NAME = :everyone
      CRUD_VERBS = ["create", "read", "update", "destroy"]
    
      def role(role_name, options = {})
        role_name = role_name.to_sym
        role_name != EVERYONE_ROLE_NAME or raise "Cannot define a role named: #{EVERYONE_ROLE_NAME}"
        @@roles_by_name[role_name] = Aegis::Role.new(role_name, self, options)
      end
      
      def find_all_role_names
        @@roles_by_name.keys
      end
      
      def find_all_roles
        @@roles_by_name.values.sort
      end
      
      def find_role_by_name(name)
        # cannot call :to_sym on nil or an empty string
        if name.blank?
          nil
        else
          @@roles_by_name[name.to_sym]
        end
      end
      
      def find_role_by_name!(name)
        find_role_by_name(name) or raise "Undefined role: #{name}"
      end
      
      def permission(*permission_name_or_names, &block)
        permission_names = Array(permission_name_or_names).map(&:to_s)
        permission_names.each do |permission_name|
          add_split_crud_permission(permission_name, &block)
        end
      end
      
      def may?(role_or_role_name, permission, *args)
        role = role_or_role_name.is_a?(Aegis::Role) ? role_or_role_name : find_role_by_name(role_or_role_name)
        blocks = @@permission_blocks[permission.to_sym]
        if blocks
          evaluate_permission_blocks(role, blocks, *args)
        else
          role.allow_by_default?
          # raise Aegis::PermissionError, "Unknown permission: #{permission}"
        end
      end
      
      def evaluate_permission_blocks(role, blocks, *args)
        result = nil
        @@permission_block_mutex.synchronize do
          @@permission_block_role_name = role.name
          @@permission_block_result = role.allow_by_default?
          blocks.each { |block| block.call(*args) }
          result = @@permission_block_result
          @@permission_block_result = nil
        end
        result
      end
      
      def allow(*role_name_or_names, &block)
        rule_encountered(role_name_or_names, true, &block)
      end
      
      def deny(*role_name_or_names, &block)
        rule_encountered(role_name_or_names, false, &block)
      end
      
      def denied?(*args)
        !allowed?(*args)
      end
      
      private
      
      def rule_encountered(role_name_or_names, is_allow, &block)
        role_names = Array(role_name_or_names)
        if role_names.include?(@@permission_block_role_name) || role_names.include?(EVERYONE_ROLE_NAME)
          @@permission_block_result = block ? block.call : true
          is_allow or @@permission_block_result = !@@permission_block_result
        end
      end

      def add_split_crud_permission(permission_name, &block)
        if permission_name =~ /^crud_(.+?)$/
          target = $1
          CRUD_VERBS.each do |verb|
            add_normalized_permission("#{verb}_#{target}", &block)
          end
        else
          add_normalized_permission(permission_name, &block)
        end
      end

      def add_normalized_permission(permission_name, &block)
        normalized_permission_name = Aegis::Normalization.normalize_permission(permission_name)
        add_singularized_permission(normalized_permission_name, &block)
      end
      
      def add_singularized_permission(permission_name, &block)
        if permission_name =~ /^([^_]+?)_(.+?)$/
          verb = $1
          target = $2
          singular_target = target.singularize
          if singular_target.length < target.length
            singular_block = lambda do |*args|
              args = args[0, args.size - 1] if args.size > 1
              block.call(*args)
            end
            singular_permission_name = "#{verb}_#{singular_target}"
            add_permission(singular_permission_name, &singular_block)
          end
        end
        add_permission(permission_name, &block)
      end
      
      def add_permission(permission_name, &block)
        permission_name = permission_name.to_sym
        @@permission_blocks[permission_name] ||= []
        @@permission_blocks[permission_name] << block
      end
      
      def invert_block(block)
        lambda { |*args| !block.call(*args) }
      end
      
      def constant_block(block, return_value)
        lambda { |*args| return_value }
      end
      
    end # module ClassMethods
    
  end # class Permissions
end # module Aegis
