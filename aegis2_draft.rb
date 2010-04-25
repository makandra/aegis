#######################################

role.name zu String

#######################################

  index     list, collection
  show      
  update    edit
  create
  destroy   delete

##############################################################################

  Actions können schreibend oder lesend sein

##############################################################################

class Permissions < Aegis::Permissions

    role :user
    role :admin
    role :student

    action :foo do

    end

    resources :properties do

        deny :guest

        writing do
          allow :admin
        end

        reading do
          allow :user
        end

        action :update do
          allow :student
        end

        action :edit_all, :collection => true # per default writing

        action :map, :writing => false

        action :seal do |duration|
          user.properties.include?(object) && duration < 5.hours
        end

        action :update do
          scope_for :user do |root|
            root.scoped(...)
          end
        end

        resources :comments do

        end

        resource :comment do
          action = :foo
        end

    end

end

#######################################
Anderes Beispiel:
#######################################

  resources :properties do
    allow :user
    permission :create do
      deny :all      # oder allow_only :admin
      allow :admin
    end
    resources :comments
    resource :map, :only => [:show] do
      allow :visitor
    end
    permission :gallery, :writing => false, :collection => true do
      allow :everyone
    end
  end

  namespace :admin do
    allow :admin
    resources :users, :only => :index
  end

#######################################
# Wird plattgemacht zu
#######################################

permission :index_admin_users
  rule = nil
  parent_rule = { allow :admin }
  takes_object = false
  takes_parent_object = false
  access_depth = :reading
end

permission :index_properties
  rule = nil
  parent_rule = { allow :user }
  takes_object = false
  takes_parent_object = false
  access_depth = :reading
end

permission :show_property
  rule = nil
  parent_rule =  { allow :user }
  takes_object = true
  takes_parent_object = false
  access_depth = :reading
end

permission :gallery_properties do
  rule = { allow :everyone }
  parent_rule = { allow :user }
  takes_object = false
  takes_parent_object = false
end

permission :create_property
  rule = { allow :visitor }
  parent_rule = { allow :user }
  takes_object = true
  takes_parent_object = false
  access_depth = :writing
end

permission :show_property_map
  rule = { :allow :visitor }
  parent_rule = { allow :user }
  takes_parent_object = true # weil geschachtelte resource
  takes_object = false # weil singleton resource
  arity = :collection
  access_depth = :reading
end





#######################################

user, object, parent_object und resource ist immer implizit da
so lässt sich z.B. Rhotheta schreiben:

Aber wie gibt mein ein sinnvolles parent_object nach oben? nicht!

#######################################

resources :root do

  writing do
    allow :user do
      user.access_for_section(resource) == 'read'
    end
    deny :user do
      user.access_for_section(resource) == 'write'
    end
  end

  resources :devices do
    like :root, :parent_object => lambda { ... }

  resources :service_stations do
    like :services
  end


end



#######################################


class CommentsController

  permissions :property_comments, :object => :set_record, :parent_object => :set_parent_record

end
