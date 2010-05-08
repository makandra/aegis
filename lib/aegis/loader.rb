class Aegis::Loader
  class << self

    def paths
      [ 'aegis/access_denied',
        'aegis/action',
        'aegis/compiler',
        'aegis/has_role',
        'aegis/parser',
        'aegis/permissions',
        'aegis/resource',
        'aegis/role',
        'aegis/sieve',

        'rails/action_controller',
        'rails/active_record' ]
    end

    def load
      for path in paths
        require path
      end
    end
    
  end
end