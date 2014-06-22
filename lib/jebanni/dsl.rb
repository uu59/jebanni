require "jebanni/request_handler"
require "jebanni/settings"

module Jebanni
  module DSL
    extend Forwardable
    def self.included(base)
      base.extend ClassMethods
      base.include Mixin
    end

    module Mixin
      def set(key, value)
        ::Jebanni::Settings[key] = value
      end

      def settings
        ::Jebanni::Settings.to_hash
      end
    end

    module ClassMethods
      include Mixin
      def register_route(verb, path, options = {}, &process)
        RequestHandler.register_route(verb, path, options, &process)
      end

      %w(get post put patch delete head options link unlink).each do |verb|
        define_method(verb) do |path, options = {}, &process|
          register_route(verb, path, options, &process)
        end
      end
    end
  end
end
