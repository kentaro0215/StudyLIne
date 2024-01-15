class StaticPagesController < ApplicationController
  def index
    return unless user_signed_in?
    redirect_to dashboard_index_path
  end

  def how_to_use; end 
end
