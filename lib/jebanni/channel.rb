module Jebanni
  class Channel
    attr_reader :id, :history, :connections, :server

    def initialize(id, server)
      @id = id
      @history = []
      @last_event_id = 0
      @server = server
      @connections = []
    end

    def join(connection)
      @connections << connection
    end

    def leave(connection)
      @connections.delete connection
    end

    def refrain(since)
      @history.each do |history|
        next if history[:id] <= since
        server.broadcast_to(self, history[:data], history[:event], history[:id])
      end
    end

    def broadcast(data, event = nil)
      @last_event_id += 1
      @history << {id: @last_event_id, event: event, data: data}
      #only keep the last 5000 Events
      if @history.size >= 6000
        @history.slice!(0, @history.size - 1000)
      end
      server.broadcast_to(self, data, event, @last_event_id)
    end
  end
end
