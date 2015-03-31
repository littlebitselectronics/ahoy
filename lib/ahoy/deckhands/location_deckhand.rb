module Ahoy
  module Deckhands
    class LocationDeckhand

      def initialize(ip)
        @ip = ip
      end

      def country
         location.country.try(:name).presence
      end

      def region
        location.subdivisions.first.try(:name).presence
      end

      def city
         location.city.try(:name).presence
      end

      protected

      def location
        if !@checked
          @location =
            begin
              Maxmind::Ipv4.lookup(@ip)
            rescue => e
              $stderr.puts e.message
              nil
            end
          @checked = true
        end
        @location
      end
    end
  end
end
