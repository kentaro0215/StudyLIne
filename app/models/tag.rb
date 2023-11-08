class Tag < ApplicationRecord
  has_many :dashboard_tags
  has_many :dashboards, through: :dashboard_tags
end
