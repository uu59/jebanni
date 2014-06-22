require "mustermann"
require "rack/utils"
require "jebanni/request_handler/processor"

module Jebanni
  class RequestHandler
    include Rack::Utils # for #parse_nested_query

    attr_reader :request, :server

    def self.register_route(verb, path, options = {}, &process)
      verb.downcase!
      @routes ||= {}
      @routes[verb] ||= []
      @routes[verb] << {
        matcher: Mustermann.new(path, options),
        process: process
      }
    end

    def initialize(request, server)
      @request = request
      @server = server
    end

    def route!
      processor.response
    end

    def find_route
      known = self.class.instance_variable_get(:@routes)
      found = known[request.method.downcase].find do |route|
        route[:matcher] === request.path
      end
      raise "not found" unless found
      found
    end

    def processor
      @processor ||=
        begin
          # Processor define class method internally, so avoid race condition for Class.new(Processor)
          processor = Class.new(Processor).new(self)
          processor.route = find_route
          processor.params = params
          processor
        end
    end

    def request_params
      query = parse_nested_query(request.query_string)
      return query if %w(get head options).include?(request.method.downcase)

      content_type = request.headers.find do |(key, _)|
        key.downcase == "content-type"
      end
      if content_type && content_type.last.downcase == "application/json"
        json_params = JSON.parse(request.body.to_s) rescue {}
        query.merge! json_params
      else
        query.merge! parse_nested_query(request.body.to_s)
      end
      query
    end

    def route_params
      find_route[:matcher].params(request.path)
    end

    def params
      # NOTE: route params is prior than query params for don't accidentally override params with query
      indiferrent_keys request_params.merge(route_params)
    end

    def indiferrent_keys(hash)
      # Either accessible params[:foo] or params["foo"]
      def hash.[](key)
        super(key.to_s) || begin
          # NOTE: Guard from DoS attack using Symbol:
          #       http://sequel.jeremyevans.net/2011/07/16/dangerous-reflection.html
          super(key.to_sym) if self.keys.map(&:to_s).include?(key.to_s)
        end
      end
      hash
    end

  end
end
