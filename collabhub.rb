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

        json_response[:timestamp] = Time.now.to_i

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
    channel << m
    nil
  end
end