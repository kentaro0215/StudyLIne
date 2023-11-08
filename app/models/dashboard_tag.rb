class DashboardTag < ApplicationRecord
  belongs_to :dashboard
  belongs_to :tag
end
