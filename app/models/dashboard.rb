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

  def self.past_month_data(year = Time.now.year, month = Time.now.month)
    # 指定された月の日数を取得
    days_in_month = Date.new(year, month, 1).next_month.prev_day.day

    # 各日のデータを0で初期化
    month_data = Array.new(days_in_month, 0)

    # 指定された月の範囲を計算
    start_date = Date.new(year, month, 1)
    end_date = Date.new(year, month, days_in_month)

    # 指定された月のデータを取得
    dashboards = self.where(created_at: start_date.beginning_of_day..end_date.end_of_day)

    # 各日のデータを集計
    dashboards.each do |dashboard|
      day = dashboard.created_at.day
      month_data[day - 1] += dashboard.total_time
    end

    month_data
  end
  # def self.past_month_data(year, month)
  #   days_in_month = Date.new(year, month, -1).day
  #   month_data = Array.new(days_in_month, 0)  # 初期データは全て0

  #   # 対象月のデータを取得
  #   dashboards = self.where(created_at: Date.new(year, month, 1)..Date.new(year, month, days_in_month))
  #   dashboards.each do |dashboard|
  #     day = dashboard.created_at.day
  #     month_data[day - 1] += dashboard.total_time
  #   end
  #   month_data
  # end


end
