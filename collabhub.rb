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
    lastmodif = if ts = params[:timestamp]
      Time.at(ts.to_i)
    else
      Time.at File.mtime( options.file )
    end

    timer = EM::PeriodicTimer.new(0.01) {
      modif = File.mtime( options.file )

      if modif.to_i > lastmodif.to_i
        timer.cancel
        EM.next_tick {
          messages = Message.find(:all, :conditions => ["created_at > ?", lastmodif.to_s(:db)])

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

    closer = lambda { timer.cancel }
    d = EM::DefaultDeferrable.new
    d.callback &closer
    d.errback &closer
    env['async.close'] = d
  end

  post '/post' do
    return if params[:msg].empty?
    Message.create!( :body => params[:msg] )
    FileUtils.touch( options.file )
  end
end