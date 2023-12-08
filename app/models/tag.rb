class Tag < ApplicationRecord
  has_many :dashboard_tags
  has_many :dashboards, through: :dashboard_tags

  def self.find_or_create_by_name(name)
    find_or_create_by(name: name)
  end
end
