class TopPagesController < ApplicationController
  
  def index
    return unless user_signed_in?
    redirect_to dashboard_index_path
  end

end
