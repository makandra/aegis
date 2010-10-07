module Aegis
  class Compiler

    ATOM_GROUPS = {
      :namespace  => :structure,
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
      for atom in atoms
        case atom_group(atom)
        when :structure
          compile_structure(atom)
        when :sieve
          compile_sieve(atom)
        else
          unexpected_atom_type!(atom)
        end
      end
    end

    def self.compile(resource, atoms)
      new(resource).compile(atoms)
    end

    private

    def compile_structure(atom)
      case atom[:type]
      when :action
        compile_action(atom)
      when :namespace
        compile_namespace(atom)
      when :resource
        compile_child_resource(atom, :singleton)
      when :resources
        compile_child_resource(atom, :collection)
      else
        unexpected_atom_type!(atom)
      end
    end

    def compile_namespace(atom)
      atom[:options].merge!(:only => [])
      compile_child_resource(atom, :singleton)
    end

    def compile_action(atom)
      action = @resource.create_or_update_action(
        atom[:name],
        create_action_options(atom[:options]),
        update_action_options(atom[:options])
      )
      for sieve_atom in atom[:children]
        compile_sieve(sieve_atom, [action])
      end
    end

    def compile_sieve(atom, affected_actions = @resource.actions)
      case atom[:type]
      when :allow
        for action in affected_actions
          action.sieves << Aegis::Sieve.new(atom[:role_name], true, atom[:block])
        end
      when :deny
        for action in affected_actions
          action.sieves << Aegis::Sieve.new(atom[:role_name], false, atom[:block])
        end
      when :reading
        for child in atom[:children]
          compile_sieve(child, @resource.reading_actions)
        end
      when :writing
        for child in atom[:children]
          compile_sieve(child, @resource.writing_actions)
        end
      else
        unexpected_atom_type!(atom)
      end
    end

    def compile_child_resource(atom, type)
      child = Aegis::Resource.new(@resource, atom[:name], type, atom[:options])
      @resource.children << child
      Aegis::Compiler.compile(child, atom[:children])
    end

    def create_action_options(options)
      { :takes_object => @resource.new_action_takes_object?(options),
        :takes_parent_object => @resource.new_action_takes_parent_object?(options)
      }.merge(update_action_options(options))
    end

    def update_action_options(options)
      { :writing => options[:writing],
        :pluralize_resource => options[:collection] }
    end

    def atom_group(atom)
      ATOM_GROUPS[atom[:type]]
    end

    def unexpected_atom_type!(atom)
      raise Aegis::InvalidSyntax, "Unexpected atom type: #{atom[:type]}"
    end

  end
end
