module Ahoy
  module Deckhands
    class LocationDeckhand

      def initialize(ip)
        @ip = ip
      end

      def country
         location.try(:country_name).presence
      end

      def region
         location.try(:subdivision_1_name).presence
      end

      def city
         location.try(:city_name).presence
      end

      protected

      def location
        if !@checked
          @location =
            begin
              Maxmind::Ipv4.lookup(@ip).location
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
