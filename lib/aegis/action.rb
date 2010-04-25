module Aegis
  class Action

    attr_reader :name, :takes_object, :takes_parent_object, :writing, :sieves, :pluralize_resource

    def initialize(name, options)
      @name = name.to_s
      @sieves = []
      update(options, true)
    end

    def update(options, use_defaults = false)
      update_attribute(options, :takes_object, use_defaults, true)
      update_attribute(options, :takes_parent_object, use_defaults, false)
      update_attribute(options, :writing, use_defaults, true)
      update_attribute(options, :pluralize_resource, use_defaults, false)
    end

    def update_attribute(options, key, use_defaults, default)
      value = options[key]
      value = default if value.nil? && use_defaults
      instance_variable_set("@#{key}", value) unless value.nil?
    end

    def may?(user, *args)
      context = extract_context(user, args)
      may = user.role.may_by_default?
      for sieve in sieves
        opinion = sieve.may?(context, *args)
        may = opinion unless opinion.nil?
      end
      may
    end

    def may!(user, *args)
      may?(user, *args) or raise Aegis::AccessDenied, "Access denied: #{args.inspect}"
    end

    def self.index(options = {})
      new('index', options.reverse_merge(:takes_object => false, :pluralize_resource => true, :writing => false))
    end

    def self.show(options = {})
      new('show', options.reverse_merge(:takes_object => true, :writing => false))
    end

    def self.update(options = {})
      new('update', options.reverse_merge(:takes_object => true, :writing => true))
    end

    def self.create(options = {})
      new('create', options.reverse_merge(:takes_object => false, :writing => true))
    end

    def self.destroy(options = {})
      new('destroy', options.reverse_merge(:takes_object => true, :writing => true))
    end

    def self.undefined
      new(nil, :takes_object => false, :writing => true)
    end

    def self.allow_to_all
      action = undefined
      action.sieves << Aegis::Sieve.allow_to_all
      action
    end

    def self.deny_to_all
      action = undefined
      action.sieves << Aegis::Sieve.deny_to_all
      action
    end

    def abstract?
      name.blank?
    end

    def inspect
      "Action(#{{ :name => name, :takes_object => takes_object, :takes_parent_object => takes_parent_object,  :sieves => sieves }.inspect})"
    end

    private

    # not *args so we can change the array reference
    def extract_context(user, args)
      context = {}
      context[:user] = user
      if takes_parent_object
        context[:parent_object] = args.shift or raise ArgumentError, "No parent object given"
      end
      if takes_object
        context[:object] = args.shift or raise ArgumentError, "No object given"
      end
      OpenStruct.new(context)
    end

  end
end
