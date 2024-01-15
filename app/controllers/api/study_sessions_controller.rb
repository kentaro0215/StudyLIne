class Api::StudySessionsController < ApplicationController
  before_action :authenticate_token_user!, except: %i[create update]
  protect_from_forgery except: %i[start finish]
  def create
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

  def update
    @study_record = token_user.study_records.find_by(finish_time: nil)
    if @study_record
      @study_record&.update(finish_time: params[:finish_time])
      @study_record.calculate_total_time
      render json: { status: 'success', data: @study_record }, status: :ok
    else
      render json: { status: 'error', message: 'Please run the `start` command first.' }, status: :unprocessable_entity
    end
  end

  private

  def token_user
    @token_user ||= User.find_by(custom_token: request.headers['Authorization'].split('Bearer ').last)
  end

  def authenticate_token_user!
    token = request.headers['Authorization'].split('Bearer ').last
    user = User.find_by(custom_token: token)
    head :unauthorized unless user
  end

  def study_record_params
    params.require(:study_record).permit(:start_time, :finish_time, tags: [])
  end
end
