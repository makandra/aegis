module Aegis
  class Resource

    attr_reader :parent, :children, :name, :type, :never_takes_object, :actions

    def initialize(parent, name, type, options)
      @parent = parent
      @children = []
      @name = name
      @type = type
      @actions = initial_actions(options)
      @never_takes_object = options[:object] == false
    end

    def find_action_by_name(name)
      name = name.to_s
      @actions.detect { |action| action.name == name }
    end

    def create_or_update_action(name, create_options, update_options)
      if action = find_action_by_name(name)
        action.update(update_options)
      else
        resource.actions << Action.new(name, create_options)
      end
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
      actions.reject(&:writing?)
    end

    def writing_actions
      actions.select(&:writing?)
    end

    def new_action_takes_object?(action_options)
      collection? && action_options[:collection] != true && !never_takes_object
    end

    def new_action_takes_parent_object?(action_options)
      parent.collection? && !parent.never_takes_object
    end

    private

    def filter_actions(actions, options)
      if options[:only]
        actions.select!(&action_name_filter(options[:only]))
      elsif options[:except]
        actions.reject!(&action_name_filter(options[:except]))
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

    def path(action)
      if root?
        action.name
      else
        [ action.name,
          parent && parent.path,
          action.pluralize_resource ? name.pluralize : name ].compact.join("_")
      end
    end

    def index_actions_by_path(index = {})
      actions.each do |action|
        index[path(action)] = action
      end
      children.each do |child|
        child.index_actions_by_path(index)
      end
      index
    end

    private

    def initial_actions_for_collection(options = {})
      filter_actions([
        Action.index,
        Action.show,
        Action.update,
        Action.show,
        Action.destroy
      ], options)
    end

    def initial_actions_for_singleton(options = {})
      filter_actions([
        Action.show(:takes_object => false),
        Action.update(:takes_object => false),
        Action.show(:takes_object => false),
        Action.destroy(:takes_object => false)
      ], options)
    end

    def initial_action_for_none(options = {})
      []
    end

  end
end
