module Aegis
  class Loader
    class << self

      def paths
        [ 'ostruct',

          'aegis/access_denied',
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

      def load_paths
        for path in paths
          require path
        end
        @loaded = true
      end

      def loaded?
        @loaded
      end

    end
  end
end
