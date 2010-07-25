module Aegis
  class Sieve

    def initialize(role_name, effect, block = nil)
      role_name = 'everyone' if role_name.blank?
      @role_name = role_name.to_s
      @effect = effect
      @block = block
    end

    def may?(context, *args)
      matches_role = @role_name == 'everyone' || @role_name == context.role.name
      if matches_role
        if @block
          block_result = context.instance_exec(*args, &@block)
          block_result ? @effect : !@effect
        else
          @effect
        end
      else
        nil
      end
    end

    def inspect
      "Sieve(#{{:role_name => @role_name, :effect => @effect ? :allow : :deny, :block => @block.present?}.inspect})"
    end

    def self.allow_to_all
      new('everyone', true)
    end

    def self.deny_to_all
      new('everyone', false)
    end

  end

end
