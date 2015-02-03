class Visit < ActiveRecord::Base
  has_many :events, class_name: "Ahoy::Event"
  belongs_to :user
end
