require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :dbfile => 'collabhub.sqlite3'
)

class Message < ActiveRecord::Base
end

#class User < ActiveRecord::Base
#end