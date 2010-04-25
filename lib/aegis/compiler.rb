module Aegis
  class Compiler

    ATOM_GROUPS = {
      :resource   => :structure,
      :resources  => :structure,
      :action     => :structure,
      :allow      => :sieve,
      :deny       => :sieve,
      :reading    => :sieve,
      :writing    => :sieve
    }

    def initialize(resource)
      @resource = resource
    end

    def compile(atoms)
      grouped_atoms = group_atoms(atoms)
      for atom in grouped_atoms[:structure]
        compile_structure(atom)
      end
      for atom in grouped_atoms[:sieve]
        compile_sieve(atom)
      end
    end

    def self.compile(resource, atoms)
      new(resource).compile(atoms)
    end

    private

    def compile_structure(atom)
      case atom[:type]
      when :action
        resource.create_or_update_action(
          atom[:name],
          create_action_options(atom[:options]),
          update_action_options(atom[:options])
        )
      when :resource
        compile_child_resource(atom, :singleton)
      when :resources
        compile_child_resource(atom, :collection)
      else
        "Unexpected atom type: #{atom[:type]}"
      end
    end

    def compile_sieve(atom, affected_actions = resource.actions)
      case atom[:type]
      when :allow
        for action in affected_actions
          action.sieves << Sieve.new(atom[:role_name], true, atom[:block])
        end
      when :deny
        for action in affected_actions
          action.sieves << Sieve.new(atom[:role_name], false, atom[:block])
        end
      when :reading
        for child in atom[:children]
          compile_sieve(child, resource.reading_actions)
        end
      when :writing
        for child in atom[:children]
          compile_sieve(child, resource.writing_actions)
        end
      else
        "Unexpected atom type: #{atom[:type]}"
      end
    end

    def compile_child_resource(atom, type)
      child = Resource.new(resource, atom[:name], type, atom[:options])
      resource.children << child
      Compiler.compile(child, atom[:children])
    end

    def create_action_options(options)
      { :takes_object => resource.new_action_takes_object?(options),
        :takes_parent_object => resource.new_action_takes_parent_object?(options)
      }.merge(update_action_options(options))
    end

    def update_action_options(options)
      { :writing => options[:writing],
        :pluralize_resource => options[:collection] }
    end

    def group_atoms(atoms)
      atoms.group_by do |atom|
        ATOM_GROUPS[atom[:type]]
      end
    end

#    def stable_sort_by(collection, &block)
#      n = 0
#      collection.sort_by do |item|
#        n += 1
#        [block.call(item), n]
#      end
#    end

  end
end
