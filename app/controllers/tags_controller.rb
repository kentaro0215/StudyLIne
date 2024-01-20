# frozen_string_literal: true

class TagsController < ApplicationController
  # before_action :set_dashboard, only: [:create]

  # def create
  #   @tags = @dashboard.tags.new(tag_params)
  #   if @tags.save
  #     render json: { status: 'success', data: @tags }, status: :ok
  #   else
  #     render json: { status: 'error', message: @tags.errors.full_messages }, status: :unprocessable_entity
  #   end
  # end

  # private

  # def set_dashboard
  #   @dashboard = Dashboard.find(params[:dashboard_id])
  # end

  # def tag_params
  #   params.require(:tag).permit(:name)
  # end
end
