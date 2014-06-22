require "jebanni/settings"
require "jebanni/channel"

module Jebanni
  class RequestHandler
    class Processor
      extend Forwardable
      def_delegators :@request_handler, :request, :server
      def_delegators :server, :async, :after, :every
      def_delegators :channel, :broadcast

      attr_accessor :params

      def initialize(request_handler)
        @request_handler = request_handler
      end

      def route=(found_route)
        @route = found_route
        self.class.send(:define_method, :process, @route[:process])
      end

      def channel_id(id)
        @channel_id = id
        unless server.channels[@channel_id]
          server.channels[@channel_id] = Channel.new(@channel_id, server)
        end
      end

      def channel
        return unless @channel_id
        server.channels[@channel_id]
      end

      def on_first_connect(&block)
        if channel.connections.length == 0
          instance_eval(&block)
        end
      end

      def finish!
        @finish = true
      end

      def finished?
        @finish
      end

      def response
        channel_id params[:channel_id] if params[:channel_id]
        process
        self
      end

      def settings
        Settings.to_hash
      end
    end
  end
end
