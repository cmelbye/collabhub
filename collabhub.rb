require 'rubygems'
require 'sinatra'
require 'environment'

class CollabHub < Sinatra::Base
  register Sinatra::Async
  set :app_file, __FILE__
  enable :static

  PushTimeout = 0.05
  
  get '/' do
    @messages = datastore.query
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

        json = json_response.to_json

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
    
    datastore[ datastore.genuid.to_s ] = { 'body' => m }
    channel << m
    nil
  end
  
  # EventMachine Channel
  def self.channel
    @channel ||= EM::Channel.new
  end

  def channel
    self.class.channel
  end
  
  # Tokyo Tyrant Table DataStore
  def self.datastore
    if TyrantHost && TyrantPort && UseTokyo
      @datastore ||= Rufus::Tokyo::TyrantTable.new( TyrantHost, TyrantPort )
    else
      @datastore ||= FakeDataStore.new
    end
  end
  
  def datastore
    self.class.datastore
  end
end
