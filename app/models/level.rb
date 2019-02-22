# frozen_string_literal: true

class Level < ApplicationRecord
  belongs_to :event_type
  validates :title, :presence => true
  validates :name, :presence => true,
                   :uniqueness => { :scope => :event_type_id }
  validates :external_id, :presence => true,
                          :uniqueness => { :scope => :event_type_id }
end
