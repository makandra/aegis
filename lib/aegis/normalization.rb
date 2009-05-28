module Aegis
  class Normalization
    
    VERB_NORMALIZATIONS = {
      "edit"   => "update",
      "show"   => "read",
      "list"   => "read",
      "view"   => "read",
      "delete" => "destroy",
      "remove" => "destroy"
    }
    
    def self.normalize_verb(verb)
      VERB_NORMALIZATIONS[verb] || verb
    end
    
    def self.normalize_permission(permission)
      if permission =~ /^([^_]+?)_(.+?)$/
        verb, target = $1, $2
        permission = normalize_verb(verb) + "_" + target
      end
      permission
    end
    
  end
end
