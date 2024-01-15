# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :study_record_tags
  has_many :study_records, through: :study_record_tags

  def self.find_or_create_by_name(name)
    find_or_create_by(name:)
  end
end
