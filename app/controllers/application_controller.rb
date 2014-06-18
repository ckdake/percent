class ApplicationController < ActionController::Base
  NoCurrentUser = Module.new

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate!

  private
  def authenticate!
    current_user
  rescue NoCurrentUser
    redirect_to signin_path
  end

  def current_user
    # @current_user ||= User.find_by_email('chris@bignerdranch.com')
    @current_user ||=
      if params.has_key?(:api_token)
        User.where(api_token: params[:api_token]).first
      else
        User.find(session[:user_id])
      end
  rescue ActiveRecord::RecordNotFound => e
    e.extend(NoCurrentUser)
    raise
  end
  helper_method :current_user

  def current_user=(user)
    session[:user_id] = user.id
    @current_user = user
  end
end
