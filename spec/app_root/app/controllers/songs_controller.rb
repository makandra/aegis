class SongsController

  require_permissions

  skip_permissions :only => :index
  permissions :songs, :only => :new

end
