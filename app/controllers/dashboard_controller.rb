class DashboardController < ApplicationController
  before_action :authenticate_user!, only: [:start, :finish]
  protect_from_forgery except: [:start, :finish] 

  def top_page
  end

  def start
    # 現在のユーザーに対して未完成のDashboardセッションを確認
    ongoing_session = current_user.dashboards.find_by(finish_time: nil)
    
    # 未完成のセッションが見つかった場合はエラーを返す
    if ongoing_session
      render json: { error: 'An ongoing study session already exists.' }, status: :bad_request
      return
    end
    
    # 新しいDashboardセッションを作成
    @dashboard = current_user.dashboards.new(start_time: params[:start_time])
    if @dashboard.save
      render json: { status: 'success', data: @dashboard }, status: :ok
    else
      render json: { status: 'error', message: @dashboard.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def finish
    @dashboard = current_user.dashboards.find_by(id: params[:id])
    if @dashboard&.update(finish_time: params[:finish_time])
      render json: { status: 'success', data: @dashboard }, status: :ok
    else
      render json: { status: 'error', message: @dashboard ? @dashboard.errors.full_messages : 'Dashboard not found' }, status: :unprocessable_entity
    end
  end

  def after_login
    @dashboards = current_user.dashboards
    @last_week_dashboards = @dashboards.past_week_date
  end

  private
  
  def authenticate_user!
    token = request.headers['Authorization'].split('Bearer ').last
    user = User.find_by(custom_token: token)
    head :unauthorized unless user
  end

  def current_user
    @current_user ||= User.find_by(custom_token: request.headers['Authorization'].split('Bearer ').last)
  end

  def dashboard_params
    params.require(:dashboard).permit(:start_time, :finish_time)
  end
end
