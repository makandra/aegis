module Aegis
  class Loader
    class << self

      def paths
        [ 'ostruct',
          'aegis/util',
          'aegis/errors',
          'aegis/action',
          'aegis/compiler',
          'aegis/has_role',
          'aegis/parser',
          'aegis/permissions',
          'aegis/resource',
          'aegis/role',
          'aegis/sieve',
          'aegis/controller',
          'aegis/active_record_ext' ]
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
