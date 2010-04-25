module Aegis
  class Role

    attr_reader :name, :default_permission

    def initialize(name, permissions, options)
      @name = name
      @permissions = permissions
      @default_permission = options[:default_permission] == :allow ? :allow : :deny
      freeze
    end

    def may_by_default?
      @default_permission == :allow
    end

    def <=>(other)
      name <=> other.name
    end

    def to_s
      name.to_s.humanize
    end

  end
end
