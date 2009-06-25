module Aegis
  class Permissions
  
    def self.inherited(base)
      base.class_eval do
        @roles_by_name = {}
        @permission_blocks = Hash.new { |hash, key| hash[key] = [] }
        extend ClassMethods
      end
    end    

    module ClassMethods
    
 
      def role(role_name, options = {})
        role_name = role_name.to_sym
        role_name != Aegis::Constants::EVERYONE_ROLE_NAME or raise "Cannot define a role named: #{Aegis::Constants::EVERYONE_ROLE_NAME}"
        @roles_by_name[role_name] = Aegis::Role.new(role_name, self, options)
      end
      
      def find_all_role_names
        @roles_by_name.keys
      end
      
      def find_all_roles
        @roles_by_name.values.sort
      end
      
      def find_role_by_name(name)
        # cannot call :to_sym on nil or an empty string
        if name.blank?
          nil
        else
          @roles_by_name[name.to_sym]
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
        blocks = @permission_blocks[permission.to_sym]
        evaluate_permission_blocks(role, blocks, *args)
      end
      
      def evaluate_permission_blocks(role, blocks, *args)
    evaluator = Aegis::PermissionEvaluator.new(role)
    evaluator.evaluate(blocks, args)
      end
      
      def denied?(*args)
        !allowed?(*args)
      end
      
      private

      def add_split_crud_permission(permission_name, &block)
        if permission_name =~ /^crud_(.+?)$/
          target = $1
          Aegis::Constants::CRUD_VERBS.each do |verb|
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
        args.delete_at 1
        instance_exec(*args, &block)
            end
            singular_permission_name = "#{verb}_#{singular_target}"
            add_permission(singular_permission_name, &singular_block)
          end
        end
        add_permission(permission_name, &block)
      end
      
      def add_permission(permission_name, &block)
        permission_name = permission_name.to_sym
        @permission_blocks[permission_name] << block
      end
 
    end # module ClassMethods
    
  end # class Permissions
end # module Aegis

