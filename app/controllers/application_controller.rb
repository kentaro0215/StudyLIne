class ApplicationController < ActionController::Base
  def authenticate_user_with_token
    token = request.headers['Authorization'].to_s.split('Bearer ').last
    @current_user = User.find_by(custom_token: token)
  
    unless @current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
  
end
