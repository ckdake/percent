class SessionsController < ApplicationController
  skip_before_action :authenticate!

  def create
    user = User.where(email: auth_hash["info"]["email"]).first_or_initialize
    user.build_oauth_token(token: auth_hash["credentials"]["token"],
                           refresh_token: auth_hash["credentials"]["refresh_token"],
                           expires_at: Time.at(auth_hash["credentials"]["expires_at"]))
    user.save!

    self.current_user = user
    redirect_to root_path
  end

  def delete
    reset_session
    render text: 'Signed out'
  end

  def signin_failed
    render text: "Unfortunately we could not log you in at this time"
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end
