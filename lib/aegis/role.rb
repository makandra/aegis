module Aegis
  class Role
  
    attr_reader :name, :default_permission
          
    # permissions is a hash like: permissions[:edit_user] = lambda { |user| ... }
    def initialize(name, permissions, options)
      @name = name
      @permissions = permissions
      @default_permission = options[:default_permission] == :allow ? :allow : :deny
      freeze
    end
    
    def allow_by_default?
      @default_permission == :allow
    end
    
    def may?(permission, *args)
      # puts "may? #{permission}, #{args}"
      @permissions.may?(self, permission, *args)
    end
    
    def <=>(other)
      name.to_s <=> other.name.to_s
    end

    def to_s
      name.to_s.humanize
    end
    
    def id
      name.to_s
    end

    private
    
    def method_missing(symb, *args)
      method_name = symb.to_s
      if method_name =~ /^may_(.+)(\?|\!)$/
        permission, severity = $1, $2
        permission = Aegis::Normalization.normalize_permission(permission)
        may = may?(permission, *args)
        if severity == '!' && !may 
          raise PermissionError, "Access denied: #{permission}" 
        else
          may
        end
      else
        super
      end
    end
        
    
  end
end
