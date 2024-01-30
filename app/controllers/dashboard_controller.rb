# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!, except: %i[start finish how_to_use]
  protect_from_forgery except: %i[start finish]

  def show
    selected_date = Date.parse(params[:date])
    start_of_day = selected_date.beginning_of_day
    end_of_day = selected_date.end_of_day

    @study_records_of_day = current_user.study_records.where(start_time: start_of_day..end_of_day)
    # @study_recordをビューで使用して編集フォームを表示
    @study_record
  end

  def edit
    @study_record = StudyRecord.find(params[:id])
  end

  def update
    @study_record = current_user.study_records.find(params[:id])
    if @study_record.update(study_record_params)
      @study_record.calculate_total_time
      redirect_to dashboard_index_path, notice: 'study_record was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @study_record = current_user.study_records.find(params[:id])
    @study_record.destroy
    redirect_to dashboard_index_path, notice: 'study_record was successfully destroyed.'
  end

  def index
    logger.info "Request Headers: #{request.headers.to_h}"
    @study_records = current_user.study_records
    @last_week_study_records_with_tags = @study_records.data_for_week_containing(Time.zone.today)

    year = params[:year].present? ? params[:year].to_i : Time.zone.now.year
    month = params[:month].present? ? params[:month].to_i : Time.zone.now.month
    @month_data = current_user.study_records.past_month_data(year, month)
    @month_data = Hash[(1..@month_data.length).zip @month_data]
    respond_to do |format|
      format.html # after_login.html.erbをレンダリング
      format.json { render json: @month_data } # JSONレスポンスを返す
    end
  end

  def years
    available_years = StudyRecord.unique_years_for_user(current_user)
    render json: { years: available_years }
  end

  def week_data
    params[:start_date].to_date

    # study_recordモデルのメソッドを使用して、指定された週のデータを取得
    render json: week_data_with_tags
  end

  private

  def authenticate_token_user!
    token = request.headers['Authorization'].split('Bearer ').last
    user = User.find_by(custom_token: token)
    head :unauthorized unless user
  end

  def token_user
    @token_user ||= User.find_by(custom_token: request.headers['Authorization'].split('Bearer ').last)
  end

  def study_record_params
    params.require(:study_record).permit(:start_time, :finish_time, tags: [])
  end
end
