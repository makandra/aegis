require 'ostruct'

#for file in Dir["#{File.dirname(__FILE__)}/*/*.rb"]
#  p file
#end

# Dir["#{File.dirname(__FILE__)}/**/*.rb"].each {|f| require f}

require 'aegis/loader'
require 'aegis/access_denied'
require 'aegis/action'
require 'aegis/compiler'
require 'aegis/has_role'
require 'aegis/parser'
require 'aegis/permissions'
require 'aegis/role'
require 'aegis/sieve'

require 'rails/action_controller'
require 'rails/active_record'
