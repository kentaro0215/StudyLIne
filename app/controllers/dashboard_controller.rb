# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_token_user!, only: %i[start finish]
  before_action :authenticate_user!, except: %i[top_page start finish how_to_use]
  protect_from_forgery except: %i[start finish]

  def top_page
    return unless user_signed_in?
    redirect_to dashboard_after_login_path
  end

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
      redirect_to study_record_after_login_path, notice: 'study_record was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @study_record = current_user.study_records.find(params[:id])
    @study_record.destroy
    redirect_to dashboard_after_login_path, notice: 'study_record was successfully destroyed.'
  end

  def start
    # 現在のユーザーに対して未完成のstudy_recordセッションを確認
    ongoing_session = token_user.study_records.find_by(finish_time: nil)

    # 未完成のセッションが見つかった場合はエラーを返す
    if ongoing_session
      render json: { error: 'An ongoing study session already exists.' }, status: :bad_request
      return
    end

    # 新しいstudy_recordセッションを作成
    @study_record = token_user.study_records.new(start_time: params[:start_time])
    @study_record.assign_tags_by_name(params[:tags]) if params[:tags].present?
    if @study_record.save
      render json: { status: 'success', data: @study_record }, status: :ok
    else
      render json: { status: 'error', message: @study_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def finish
    @study_record = token_user.study_records.find_by(finish_time: nil)
    if @study_record
      @study_record&.update(finish_time: params[:finish_time])
      @study_record.calculate_total_time
      render json: { status: 'success', data: @study_record }, status: :ok
    else
      render json: { status: 'error', message: 'Please run the `start` command first.' }, status: :unprocessable_entity
    end
  end

  def after_login
    logger.info "Request Headers: #{request.headers.to_h}"
    @study_records = current_user.study_records
    @last_week_study_records_with_tags = @study_records.data_for_week_containing(Date.today)
    year = params[:year].present? ? params[:year].to_i : Time.now.year
    month = params[:month].present? ? params[:month].to_i : Time.now.month
    @month_data = current_user.study_records.past_month_data(year, month)
    @month_data = Hash[(1..@month_data.length).zip @month_data]
    respond_to do |format|
      format.html # after_login.html.erbをレンダリング
      format.json { render json: @month_data } # JSONレスポンスを返す
    end
  end

  def week_data
    start_date = params[:start_date].to_date

    # study_recordモデルのメソッドを使用して、指定された週のデータを取得
    week_data_with_tags = current_user.study_records.data_for_week_containing(start_date)

    render json: week_data_with_tags
  end

  def how_to_use; end

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
