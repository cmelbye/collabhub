require 'rubygems'
require 'sinatra'
require 'sinatra/async'
require 'json'

class CollabHub < Sinatra::Base
  def self.channel
    @channel ||= EM::Channel.new
  end

  def channel
    self.class.channel
  end

  PushTimeout = 0.05

  register Sinatra::Async
  set :app_file, __FILE__
  enable :static

  configure do
    set :file, File.dirname(__FILE__) + '/data.txt'
  end

  get '/' do
    erb :index
  end

  aget '/grab' do
    message_buffer = []
    timer = nil
    sid = channel.subscribe { |message|
      message_buffer << message

      timer ||= EM::Timer.new(PushTimeout) {
        json_response = {}
        json_response[:messages] = []

        message_buffer.each do |message|
          json_response[:messages] << { :id => message_buffer.index(message), :body => message, :created_at => Time.now }
        end

<<<<<<< HEAD:collabhub.rb
          for message in messages
            json_response[:messages] << { :id => message.id, :body => message.body, :sender => message.sender, :created_at => message.created_at }
          end
=======
        json_response[:timestamp] = Time.now.to_i
>>>>>>> e798afd43b53189bb0d5ed2e5b0d5c6442537ecb:collabhub.rb

        json = json_response.to_json

        response['Cache-Control'] = "max-age=0"

        body json
      }
    }

    closer = lambda {
      channel.unsubscribe sid
      timer.cancel if timer
    }
    d = env['async.close']
    d.callback &closer
    d.errback &closer
  end

  post '/post' do
    m = params[:msg]
    return if m.nil? || m.empty?
<<<<<<< HEAD:collabhub.rb
    
    u = params[:username]
    k = params[:authkey]
    t = params[:authtoken]
    hash = t.to_s + "+++" + u.to_s + "+++" + "CollabHubAuthentication"
    hash = Digest::SHA256.hexdigest( hash )
    
    if u.empty? || k.empty? || t.empty?
      username = 'Anonymous'
    else
      return if hash != k
      username = u
    end
    
    Message.create!( :body => m, :sender => u )
    FileUtils.touch( options.file )
=======
    channel << m
    nil
>>>>>>> e798afd43b53189bb0d5ed2e5b0d5c6442537ecb:collabhub.rb
  end
end
