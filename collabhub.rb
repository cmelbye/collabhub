require 'rubygems'
require 'sinatra'
require 'sinatra/async'
require 'active_record'
require 'json'
require 'models'
require 'fileutils'

class CollabHub < Sinatra::Base
  register Sinatra::Async
  
  configure do
    set :file, File.dirname(__FILE__) + '/data.txt'
  end
  
  before do
    @defer = false
  end
  
  get '/' do
    erb :index
  end
  
  aget '/grab' do
    @defer = true
    
    modif = File.mtime( options.file ).to_i
    lastmodif = defined?(params[:timestamp]) ? params[:timestamp].to_i : 0
    latest = defined?(params[:latest]) ? params[:latest].to_i : 0
    file = File.new( options.file, 'r' )
    
    while modif <= lastmodif
      sleep(0.01)
      modif = File.mtime( options.file ).to_i
    end
    
    messages = Message.find(:all, :conditions => "id > #{latest}")
    
    latest = Message.last
    
    json_response = {}
    json_response[:messages] = []
    
    for message in messages
      json_response[:messages] << { :id => message.id, :body => message.body, :created_at => message.created_at }
    end
    
    json_response[:timestamp] = modif
  
    if latest
      json_response[:latest] = latest.id
    else
      json_response[:latest] = 0
    end
    
    json = json_response.to_json
    
    response['Cache-Control'] = "max-age=0"
    
    body json
  end
  
  post '/post' do
    if params[:msg].empty?
      return
    end
    
    @message = Message.new( :body => params[:msg] )
    @message.save
    
    FileUtils.touch( options.file )
  end
end
class Sinatra::Application
  def deferred?(env)
    return true if @defer
  end
end
