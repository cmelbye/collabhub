# Gems and such

require 'rubygems'
require 'sinatra/async'
require 'json'

# Should we be using Tokyo?
begin
  require 'rufus/tokyo/tyrant'
  UseTokyo = true
rescue LoadError
  require 'fakedatastore'
  UseTokyo = false
end
