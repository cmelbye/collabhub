require 'rubygems'
require 'sinatra'
require 'sinatra/async'
require 'activerecord'
require 'json'
require 'models'
require 'fileutils'

class CollabHub < Sinatra::Base
  register Sinatra::Async

  configure do
    set :file, File.dirname(__FILE__) + '/data.txt'
  end

  get '/' do
    erb :index
  end

  aget '/grab' do
    lastmodif = params[:timestamp] || File.mtime( options.file )

    timer = EM::PeriodicTimer.new(0.01) {
      modif = File.mtime( options.file )

      if modif.to_i > lastmodif.to_i
        timer.cancel
        EM.next_tick {
          messages = Message.find(:all, :conditions => "created_at > #{lastmodif.to_s(:db)}")

          latest = Message.last

          json_response = {}
          json_response[:messages] = []

          for message in messages
            json_response[:messages] << { :id => message.id, :body => message.body, :created_at => message.created_at }
          end

          json_response[:timestamp] = modif.to_i

          json = json_response.to_json

          response['Cache-Control'] = "max-age=0"

          body json
        }
      end
    }
    
    env['async.close'] = lambda { timer.cancel }
  end

  post '/post' do
    return if params[:msg].empty?
    Message.create!( :body => params[:msg] )
    FileUtils.touch( options.file )
  end
end