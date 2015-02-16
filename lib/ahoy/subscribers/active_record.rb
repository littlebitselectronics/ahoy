module Ahoy
  module Subscribers
    class ActiveRecord

      def initialize(options = {})
        @model = options[:model] || Ahoy::Event
      end

      def track(name, properties, options = {})
        @model.create! do |e|
          e.visit = options[:visit]
          e.user = options[:user]
          e.name = name
          e.properties = properties
        end
      end

    end
  end
end
