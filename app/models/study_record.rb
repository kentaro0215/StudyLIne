# frozen_string_literal: true

class StudyRecord< ApplicationRecord
  belongs_to :user
  has_many :study_record_tags , dependent: :destroy
  has_many :tags, through: :study_record_tags

  def calculate_total_time
    return unless start_time && finish_time

    self.total_time = ((finish_time - start_time) / 60).to_i
    save
  end

  def self.past_week_date
    this_week_dashboards = []
    6.downto(0) do |n|
      daily_dashboards = where(created_at: n.day.ago.all_day).sum(:total_time)
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
    dashboards = where(created_at: start_date.beginning_of_day..end_date.end_of_day)

    # 各日のデータを集計
    dashboards.each do |dashboard|
      day = dashboard.created_at.day
      month_data[day - 1] += dashboard.total_time || 0
    end

    month_data
  end

  def assign_tags_by_name(tag_name)
    tag_name.each do |name|
      tag = Tag.find_or_create_by_name(name)
      tags << tag unless tags.include?(tag)
    end
  end

  def self.data_for_week_containing(date)
    # 与えられた日付が含まれる週の月曜日を見つける
    monday = date.at_beginning_of_week
    week_data_with_tags = []
    7.times do |n|
      day = monday + n.days
      daily_dashboards = where(created_at: day.all_day)
      daily_data = daily_dashboards.joins(:tags).group('tags.name').sum(:total_time)
      week_data_with_tags << { date: day, data: daily_data }
    end

    week_data_with_tags
  end

    # ユーザーに属するユニークな年を取得
    def self.unique_years_for_user(user)
      where(user: user)
        .group(Arel.sql("DATE_PART('year', created_at)"))
        .pluck(Arel.sql("DATE_PART('year', created_at)"))
    end

end
