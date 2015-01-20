module Ahoy
  class Event < ActiveRecord::Base
    self.table_name = "ahoy_events"

    belongs_to :visit
    has_many :properties, class_name: "Ahoy::EventProperty"
    belongs_to :user
  end
end
