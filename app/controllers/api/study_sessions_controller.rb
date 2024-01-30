# frozen_string_literal: true

module Api
  class StudySessionsController < ApplicationController
    before_action :authenticate_token_user!, except: %i[create update]
    protect_from_forgery except: %i[start finish]
    def create
      # 現在のユーザーに対して未完成のstudy_recordセッションを確認
      ongoing_session = token_user.study_records.find_by(finish_time: nil)

      # 未完成のセッションが見つかった場合はエラーを返す
      if ongoing_session
        render json: { error: 'すでに始まっている学習セッションがあります。そのセッションを終わらせてください。' }, status: :bad_request
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
        render json: { status: 'error', message: 'startコマンドを最初に入力してください。' },
        status: :unprocessable_entity
      end
    end
  end
end