module Jebanni
  module Settings
    class << self
      def []=(key, value)
        @settings ||= {}
        @settings[key] = value
      end

      def [](key)
        @settings ||= {}
        @settings[key]
      end

      def to_hash
        @settings || {}
      end
    end
  end
end
