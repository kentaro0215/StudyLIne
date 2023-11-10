class Dashboard < ApplicationRecord
  belongs_to :user
  has_many :dashboard_tags
  has_many :tags, through: :dashboard_tags
  
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
      month_data[day - 1] += dashboard.total_time || 0  
    end

    month_data
  end

  #　タグごとの勉強時間を計算
  # def tag_total_time
  #   dashboards.joins(:tags).group('tags.name').sum('dashboards.total_time')
  # end

  def assign_tags_by_name(tag_name)
    tag_name.each do |name|
      tag = Tag.find_or_create_by_name(name)
      self.tags << tag unless self.tags.include?(tag)
    end
  end

  def self.past_week_date_with_tags
    # 一週間分のデータを格納する配列を初期化
    week_data_with_tags = []
  
    # 今日から過去6日間にわたってデータを集計
    6.downto(0) do |n|
      # その日のダッシュボードを取得
      daily_dashboards = self.where(created_at: n.day.ago.all_day)
  
      # タグごとに集計
      daily_data = daily_dashboards.joins(:tags).group('tags.name').sum(:total_time)
      # 日付とともにハッシュに追加
      week_data_with_tags << { date: n.day.ago.to_date, data: daily_data }
    end
  
    week_data_with_tags
  end
  
  
end
