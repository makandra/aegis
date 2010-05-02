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

    def action(*args, &block)
      split_definitions(*args) do |name, options|
        @atoms.push({
          :type => :action,
          :name => name.to_s,
          :options => options,
          :children => Aegis::Parser.parse(&block)
        })
      end
    end

    def namespace(*args, &block)
      split_definitions(*args) do |name, options|
        @atoms.push({
          :type => :namespace,
          :name => name.to_s,
          :options => options,
          :children => Aegis::Parser.parse(&block)
        })
      end
    end

    def resource(*args, &block)
      split_definitions(*args) do |name, options|
        @atoms.push({
          :type => :resource,
          :name => name.to_s,
          :options => options,
          :children => Aegis::Parser.parse(&block)
        })
      end
    end

    def resources(*args, &block)
      split_definitions(*args) do |name, options|
        @atoms.push({
          :type => :resources,
          :name => name.to_s,
          :options => options,
          :children => Aegis::Parser.parse(&block)
        })
      end
    end

    def allow(*args, &block)
      split_definitions(*args) do |role_name, options|
        @atoms.push({
          :type => :allow,
          :role_name => role_name.to_s,
          :block => block
        })
      end
    end

    def deny(*args, &block)
      split_definitions(*args) do |role_name, options|
        @atoms.push({
          :type => :deny,
          :role_name => role_name.to_s,
          :block => block
        })
      end
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

    private

    def split_definitions(*args, &definition)
      options = args.extract_options!
      args = [nil] if args.empty?
      for name in args
        definition.call(name, options)
      end
    end

  end
end
