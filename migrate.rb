require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :dbfile => 'collabhub.sqlite3'
)

class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :body
      t.timestamps
    end
  end
end

CreateMessages.migrate(:up)