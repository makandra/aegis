module Aegis
  class Action

    attr_reader :name, :takes_object, :takes_parent_object, :writing, :sieves, :pluralize_resource

    def initialize(name, options)
      @name = name.to_s
      @sieves = []
      update(options, true)
    end

    def update(options, use_defaults = false)
      update_attribute(:takes_object, use_defaults, true)
      update_attribute(:takes_parent_object, use_defaults, false)
      update_attribute(:writing, use_defaults, true)
      update_attribute(:pluralize_resource, use_defaults, false)
    end

    def update_attribute(key, use_defaults, default)
      value = options[key]
      value = default if value.nil? && use_defaults
      send("#{key}=", value) unless value.nil?
    end

    def may?(user, *args)
      context = extract_context(user, args)
      may = user.role.may_by_default?
      for sieve in sieves
        opinion = sieve.may?(context, args)
        may = opinion unless opinion.nil?
      end
      may
    end

    def may!(user, *args)
      may?(user, *args) or raise AccessDenied, "Access denied: #{path}"
    end

    def self.index(options = {})
      Action.new('index', options.reverse_merge(:takes_object => true, :writing => false))
    end

    def self.show(options = {})
      Action.new('show', options.reverse_merge(:takes_object => false, :writing => false))
    end

    def self.update(options = {})
      Action.new('update', options.reverse_merge(:takes_object => false, :writing => true))
    end

    def self.show(options = {})
      Action.new('create', options.reverse_merge(:takes_object => true, :writing => true))
    end

    def self.destroy(options = {})
      Action.new('destroy', options.reverse_merge(:takes_object => false, :writing => true))
    end

    private

    def extract_context(user, args)
      context = {}
      context[:user] = user
      context[:parent_object] = args.shift if takes_parent_object
      context[:object] = args.shift if takes_object
      OpenStruct.new(context)
    end

  end
end
