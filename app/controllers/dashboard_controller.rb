class DashboardController < ApplicationController
  before_action :authenticate_user!, only: [:start, :finish]
  protect_from_forgery except: [:start, :finish] 

  def top_page
  end

  def start
    # 現在のユーザーに対して未完成のDashboardセッションを確認
    ongoing_session = token_user.dashboards.find_by(finish_time: nil)
    
    # 未完成のセッションが見つかった場合はエラーを返す
    if ongoing_session
      render json: { error: 'An ongoing study session already exists.' }, status: :bad_request
      return
    end
    
    # 新しいDashboardセッションを作成
    @dashboard = token_user.dashboards.new(start_time: params[:start_time])
    @dashboard.assign_tags_by_name(params[:tags]) if params[:tags].present?
    if @dashboard.save
      render json: { status: 'success', data: @dashboard }, status: :ok
    else
      render json: { status: 'error', message: @dashboard.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def finish
    @dashboard = token_user.dashboards.find_by(finish_time: nil)
    if @dashboard&.update(finish_time: params[:finish_time])
      @dashboard.calculate_total_time
      render json: { status: 'success', data: @dashboard }, status: :ok
    else
      render json: { status: 'error', message: @dashboard ? @dashboard.errors.full_messages : 'Dashboard not found' }, status: :unprocessable_entity
    end
  end

  def after_login
    @dashboards = current_user.dashboards
    #　タグごとの勉強時間を計算
    @tags = current_user.all_tags
    # タグごとの勉強時間を計算
    @tags_total_time = current_user.tag_total_time
    @last_week_dashboards = @dashboards.past_week_date
    @last_week_dashboards_with_tags = @dashboards.past_week_date_with_tags
    year = params[:year].present? ? params[:year].to_i : Time.now.year
    month = params[:month].present? ? params[:month].to_i : Time.now.month
    @month_data = Dashboard.past_month_data(year, month)
    @month_data = Hash[(1..@month_data.length).zip @month_data]
    respond_to do |format|
      format.html  # after_login.html.erbをレンダリング
      format.json { render json: @month_data }  # JSONレスポンスを返す
    end
  end

  private
  
  def authenticate_user!
    token = request.headers['Authorization'].split('Bearer ').last
    user = User.find_by(custom_token: token)
    head :unauthorized unless user
  end

  # def current_user
  #   @current_user ||= User.find_by(custom_token: request.headers['Authorization'].split('Bearer ').last)
  # end

  def token_user
    @token_user ||= User.find_by(custom_token: request.headers['Authorization'].split('Bearer ').last)
  end

  def dashboard_params
    params.require(:dashboard).permit(:start_time, :finish_time, :tags [])
  end
end
