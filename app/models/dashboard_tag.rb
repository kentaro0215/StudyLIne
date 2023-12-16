# frozen_string_literal: true

class DashboardTag < ApplicationRecord
  belongs_to :dashboard
  belongs_to :tag
end
