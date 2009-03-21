require 'rubygems'
require 'sinatra'
require 'active_record'
require 'json'
require 'models'
require 'fileutils'

configure do
  set :file, File.dirname(__FILE__) + '/data.txt'
end

before do
  new_params = {}
  params.each_pair do |full_key, value|
    this_param = new_params
    split_keys = full_key.split(/\]\[|\]|\[/)
    split_keys.each_index do |index|
      break if split_keys.length == index + 1
      this_param[split_keys[index]] ||= {}
      this_param = this_param[split_keys[index]]
   end
   this_param[split_keys.last] = value
  end
  request.params.replace new_params
  
  @defer = false
end

get '/' do
  erb :index
end

get '/grab' do
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
  
  response = {}
  response[:messages] = []
  
  for message in messages
    response[:messages] << { :id => message.id, :body => message.body, :created_at => message.created_at }
  end
  
  response[:timestamp] = modif
  
  if latest
    response[:latest] = latest.id
  else
    response[:latest] = 0
  end
  
  json = response.to_json
  
  return json
end

post '/post' do
  if params[:msg].empty?
    return
  end
  
  @message = Message.new( :body => params[:msg] )
  @message.save
  
  FileUtils.touch( options.file )
end

class Sinatra::Application
  def deferred?(env)
    return true if @defer
  end
end
