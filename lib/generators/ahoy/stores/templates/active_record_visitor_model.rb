class Visitor < ActiveRecord::Base
  has_many :ahoy_events, class_name: "Ahoy::Event"
  has_many :visits
end
