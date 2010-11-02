class Permissions < Aegis::Permissions

  role :user

  missing_user_means { User.new(:role_name => 'user') }

  resources :properties do
    resources :reviews do
      reading do
        allow :user
      end
    end
  end

end

