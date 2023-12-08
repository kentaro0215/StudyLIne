class DashboardController < ApplicationController
  before_action :authenticate_token_user!, only: [:start, :finish]
  before_action :authenticate_user!, except: [:top_page, :start, :finish, :how_to_use]
  protect_from_forgery except: [:start, :finish] 

  def top_page
    if user_signed_in?
      redirect_to dashboard_after_login_path
    end
  end
  
  def show
    selected_date = Date.parse(params[:date])
    start_of_day = selected_date.beginning_of_day
    end_of_day = selected_date.end_of_day
  
    @dashboards_of_day = current_user.dashboards.where(start_time: start_of_day..end_of_day)
    # @dashboardをビューで使用して編集フォームを表示
    @dashboard
  end

  def edit
    @dashboard = Dashboard.find(params[:id])
  end

  def update
    @dashboard = current_user.dashboards.find(params[:id])
    if @dashboard.update(dashboard_params)
      @dashboard.calculate_total_time
      redirect_to dashboard_after_login_path, notice: 'Dashboard was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @dashboard = current_user.dashboards.find(params[:id])
    @dashboard.destroy
    redirect_to dashboard_after_login_path, notice: 'Dashboard was successfully destroyed.'
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
    logger.info "Request Headers: #{request.headers.to_h}"
    @dashboards = current_user.dashboards
    @last_week_dashboards_with_tags = @dashboards.data_for_week_containing(Date.today)
    year = params[:year].present? ? params[:year].to_i : Time.now.year
    month = params[:month].present? ? params[:month].to_i : Time.now.month
    @month_data = current_user.dashboards.past_month_data(year, month)
    @month_data = Hash[(1..@month_data.length).zip @month_data]
    respond_to do |format|
      format.html  # after_login.html.erbをレンダリング
      format.json { render json: @month_data }  # JSONレスポンスを返す
    end
  end

  def week_data
    start_date = params[:start_date].to_date
  
    # Dashboardモデルのメソッドを使用して、指定された週のデータを取得
    week_data_with_tags = current_user.dashboards.data_for_week_containing(start_date)
  
    render json: week_data_with_tags
  end

  def how_to_use
  end

  private

  def authenticate_token_user!
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
    params.require(:dashboard).permit(:start_time, :finish_time, tags: [])
  end

end
