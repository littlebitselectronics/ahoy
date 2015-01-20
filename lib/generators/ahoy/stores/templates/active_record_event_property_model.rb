module Ahoy
  class EventProperty < ActiveRecord::Base
    self.table_name = "ahoy_event_properties"

    belongs_to :event, class_name: "Ahoy::Event"
  end
end