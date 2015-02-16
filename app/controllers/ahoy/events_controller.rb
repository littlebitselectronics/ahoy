module Ahoy
  class EventsController < Ahoy::BaseController

    def create
      events =
        if params[:name]
          # legacy API
          [params]
        else
          begin
            ActiveSupport::JSON.decode(request.body.read)
          rescue ActiveSupport::JSON.parse_error
            # do nothing
            []
          end
        end

      events.each do |event|
        options = {
          id: event["id"]
        }
        ahoy.track event["name"], event["properties"], options
      end
      render json: {}
    end

  end
end
