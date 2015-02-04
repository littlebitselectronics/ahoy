class Visitor < ActiveRecord::Base
  has_many :events, class_name: "Ahoy::Event"
  has_many :visits, autosave: true

  before_create :generate_uuid

  private

  def generate_uuid
    self.id = SecureRandom.uuid
  end
end
