module Aegis
  class Parser

    attr_reader :atoms

    def self.parse(&block)
      Aegis::Parser.new.parse(&block)
    end

    def initialize
      @atoms = []
    end

    def parse(&block)
      instance_eval(&block) if block
      atoms
    end

    def action(name, options = {}, &block)
      @atoms.push({
        :type => :action,
        :name => name.to_s,
        :options => options,
        :children => Aegis::Parser.parse(&block)
      })
    end

    def namespace(name, options = {}, &block)
      @atoms.push({
        :type => :namespace,
        :name => name.to_s,
        :options => options,
        :children => Aegis::Parser.parse(&block)
      })
    end

    def resource(name, options = {}, &block)
      @atoms.push({
        :type => :resource,
        :name => name.to_s,
        :options => options,
        :children => Aegis::Parser.parse(&block)
      })
    end

    def resources(name, options = {}, &block)
      @atoms.push({
        :type => :resources,
        :name => name.to_s,
        :options => options,
        :children => Aegis::Parser.parse(&block)
      })
    end

    def allow(role_name = nil, &block)
      @atoms.push({
        :type => :allow,
        :role_name => role_name.to_s,
        :block => block
      })
    end

    def deny(role_name = nil, &block)
      @atoms.push({
        :type => :deny,
        :role_name => role_name.to_s,
        :block => block
      })
    end

    def reading(&block)
      block or raise "missing block"
      @atoms.push({
        :type => :reading,
        :children => Aegis::Parser.parse(&block)
      })
    end

    def writing(&block)
      block or raise "missing block"
      @atoms.push({
        :type => :writing,
        :children => Aegis::Parser.parse(&block)
      })
    end

  end
end
