module Aegis
  class Sieve

    def initialize(role_name, effect, &block)
      @role_name = (role_name || 'everyone').to_s
      @effect = effect
      @block = block
    end

    def may?(context, *args)
      matches_role = @role_name == 'everyone' || @role_name == context.user.role_name
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

  end

end
