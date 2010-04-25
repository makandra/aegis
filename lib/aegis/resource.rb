module Aegis
  class Resource

    attr_reader :parent, :children, :name, :type, :never_takes_object, :actions

    def initialize(parent, name, type, options)
      @parent = parent
      @children = []
      @name = name
      @type = type
      @actions = initial_actions(options)
      # @never_takes_object = options[:object] == false
    end

    def inspect
      "Resource(#{{:name => name || 'root', :actions => actions, :children => children, :parent => parent}.inspect})"      
    end

    def find_action_by_name(name)
      name = name.to_s
      @actions.detect { |action| action.name == name }
    end

    def create_or_update_action(name, create_options, update_options)
      action = nil
      if action = find_action_by_name(name)
        action.update(update_options)
      else
        action = Action.new(name, create_options)
        @actions << action
      end
      action
    end

    def root?
      type == :root
    end

    def singleton?
      type == :singleton
    end

    def collection?
      type == :collection
    end

    def reading_actions
      actions.reject(&:writing)
    end

    def writing_actions
      actions.select(&:writing)
    end

    def action_path(action)
      if root?
        action.name
      else
        [ action.name,
          parent && parent.path(false),
          action.pluralize_resource ? name.pluralize : name.singularize ].select(&:present?).join("_")
      end
    end

    def index_actions_by_path(index = {})
      actions.each do |action|
        index[action_path(action)] = action
      end
      children.each do |child|
        child.index_actions_by_path(index)
      end
      index
    end

    def new_action_takes_object?(action_options = {})
      collection? && action_options[:collection] != true # && !never_takes_object
    end

    def new_action_takes_parent_object?(action_options = {})
      parent && parent.collection? # && !parent.never_takes_object
    end

    protected

    def path(pluralize = true)
      parent_path = parent && parent.path(false)
      pluralized_name = name ? (pluralize ? name.pluralize : name.singularize) : nil
      [parent_path, pluralized_name].select(&:present?).join("_")
    end

    private

    def filter_actions(actions, options)
      if options[:only]
        actions = actions.select(&action_name_filter(options[:only]))
      elsif options[:except]
        actions = actions.reject(&action_name_filter(options[:except]))
      end
      actions
    end

    def action_name_filter(whitelist)
      whitelist = whitelist.collect(&:to_s)
      lambda { |action| whitelist.include?(action.name) }
    end

    def initial_actions(options)
      send("initial_actions_for_#{type}", options)
    end

    def initial_actions_for_collection(options = {})
      filter_actions([
        Aegis::Action.index(initial_action_options),
        Aegis::Action.show(initial_action_options),
        Aegis::Action.update(initial_action_options),
        Aegis::Action.create(initial_action_options),
        Aegis::Action.destroy(initial_action_options),
      ], options)
    end

    def initial_actions_for_singleton(options = {})
      filter_actions([
        Aegis::Action.show(initial_action_options(:takes_object => false)),
        Aegis::Action.update(initial_action_options(:takes_object => false)),
        Aegis::Action.create(initial_action_options(:takes_object => false)),
        Aegis::Action.destroy(initial_action_options(:takes_object => false))
      ], options)
    end

    def initial_action_options(options = {})
      { :takes_parent_object => new_action_takes_parent_object? }.merge(options)
    end

    def initial_actions_for_root(options = {})
      []
    end

  end
end
