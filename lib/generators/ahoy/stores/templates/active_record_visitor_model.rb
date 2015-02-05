class Visitor < ActiveRecord::Base
  has_many :events, class_name: "Ahoy::Event"
  has_many :visits, autosave: true
end
