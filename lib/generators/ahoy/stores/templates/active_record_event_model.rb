module Ahoy
  class Event < ActiveRecord::Base
    self.table_name = "ahoy_events"

    belongs_to :visit
    belongs_to :user
    has_many :properties, class_name: "Ahoy::EventProperty", autosave: true, dependent: :destroy

  end
end
