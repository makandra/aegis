class Permissions < Aegis::Permissions

  role :user

  resources :properties do
    resources :reviews do
      reading do
        allow :user
      end
    end
  end

  resources :maps do
    action :with_permission, :collection => true
  end

end

