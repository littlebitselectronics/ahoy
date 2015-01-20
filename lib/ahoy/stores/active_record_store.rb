module Ahoy
  module Stores
    class ActiveRecordStore < BaseStore

      def track_visit(options, &block)
        visit =
          visit_model.new do |v|
            v.id = ahoy.visit_id
            v.visitor_id = ahoy.visitor_id
            v.user = user if v.respond_to?(:user=)
            v.anonymous_user = anonymous_user if v.respond_to?(:anonymous_user=)
            v.started_at = options[:started_at]
          end

        set_visit_properties(visit)

        yield(visit) if block_given?

        begin
          visit.save!
          geocode(visit)
        rescue *unique_exception_classes
          # do nothing
        end
      end

      def track_event(name, properties, options, &block)
        event =
          event_model.new do |e|
            e.id = options[:id]
            e.visit_id = ahoy.visit_id
            e.user = user
            e.anonymous_user = anonymous_user
            e.name = name
            e.time = options[:time]
            properties.each do |name, value|
              # put a binding.pry in here and checkout why you are getting the following error
              #"Mysql2::Error - Out of range value for column 'event_id' at row 1"
              e.properties.build(name: name, value: value)
            end
          end

        yield(event) if block_given?

        begin
          event.save!
        rescue *unique_exception_classes
          # do nothing
        end
      end

      def visit
        @visit ||= visit_model.where(id: ahoy.visit_id).first if ahoy.visit_id
      end

      protected

      def visit_model
        ::Visit
      end

      def event_model
        ::Ahoy::Event
      end

    end
  end
end
