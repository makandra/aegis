class Permissions < Aegis::Permissions

  role :user

  resources :properties do
    resources :reviews do
      reading do
        allow :user
      end
    end
  end

end

