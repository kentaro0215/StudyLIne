class Dashboard < ApplicationRecord
  belongs_to :user

  def calculate_total_time
    return unless start_time && finish_time
    self.total_time = ((finish_time - start_time) / 60).to_i
    save
  end
  
  def self.past_week_date
    this_week_dashboards = []
    6.downto(0) do |n|
      daily_dashboards = self.where(created_at: n.day.ago.all_day).sum(:total_time)
      this_week_dashboards << daily_dashboards
    end
    this_week_dashboards
  end

end
