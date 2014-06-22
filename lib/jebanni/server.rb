require 'time'
require 'reel'

# Based on Reel's sample
# https://github.com/celluloid/reel/blob/master/examples/server_sent_events.rb

module Jebanni
  class Server < Reel::Server::HTTP
    include Celluloid::Logger
    
    def initialize(ip = '127.0.0.1', port = 63310)
      @channels = {}
      super(ip, port, &method(:on_connection))
      async.ping
    end

    def broadcast_to(channel, data, event, id)
      channel.connections.each do |socket|
        async.send_sse(socket, data, event, id)
      end
      true
    end

    def channels
      @channels
    end

    def all_connections
      @channels.map{|(_, channel)| channel.connections}.flatten
    end

    private
    #event and id are optional, Eventsource only needs data
    def send_sse(socket, data, event = nil, id = nil)
      unless data.is_a? String
        data = JSON.dump(data)
      end
      socket.id id if id
      socket.event event if event
      socket.data data
    rescue Reel::SocketError
      leave_channel(socket)
    end

    def leave_channel(socket)
      @channels.each do |id, ch|
        next unless ch.connections.include?(socket)
        debug("Disconnect from channel:#{id}")
        ch.leave(socket)
      end
    end

    #Lines that start with a Colon are Comments and will be ignored
    def send_ping
      all_connections.each do |socket|
        begin
          socket << ": ping\n"
        rescue Reel::SocketError
          leave_channel(socket)
        end
      end
    end

    #apache 2.2 closes connections after five seconds when nothing is send, see this as a poor mans Keep-Alive
    def ping
      every(5) do
        send_ping
      end
    end

    def handle_request(request)
      response = RequestHandler.new(request, self).route!
      return request.respond 204 if response.finished?

      request.respond Reel::StreamResponse.new(:ok, response_headers, event_stream(request, response))
    end

    def response_headers
      #X-Accel-Buffering is nginx(?) specific. Setting this to "no" will allow unbuffered responses suitable for Comet and HTTP streaming applications
      {
        'Content-Type' => 'text/event-stream; charset=utf-8',
        'Cache-Control' => 'no-cache',
        'X-Accel-Buffering' => 'no',
        'Access-Control-Allow-Origin' => '*',
      }
    end

    def event_stream(request, response)
      Reel::EventStream.new do |socket|
        channel = response.channel
        channel.join socket
        socket.retry 5000
        #after a Connection reset resend newer Messages to the Client, query['lastEventId'] is needed for https://github.com/Yaffle/EventSource
        query = Hash[URI.decode_www_form(request.query_string || "")]
        id = (request.headers['Last-Event-ID'] || query['lastEventId'])
        socket << "id\n\n"
        if id && id.to_i > 0
          channel.refrain(id.to_i)
        end
      end
    end

    def on_connection(connection)
      connection.each_request do |request|
        handle_request(request)
      end
    end
  end
end
