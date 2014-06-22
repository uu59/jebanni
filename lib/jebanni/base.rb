require "jebanni/dsl"
require "jebanni/server"

module Jebanni
  class Base
    include ::Jebanni::DSL

    def self.run
      new.run
    end

    def run
      bind = settings[:bind] || "0.0.0.0"
      port = settings[:port] || 63311
      @server = Server.new(bind, port)
      trap "INT" do
        @server.terminate if @server and @server.alive?
        exit
      end
      @server.send(:info, "Listen on #{bind}:#{port}")
      sleep
    end
  end
end
