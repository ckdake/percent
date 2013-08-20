require Rails.root.join('lib', 'access_token')

class DashboardsController < ApplicationController
  def show
    @percent_report = PercentReport.new(AccessToken.new(current_user.oauth_token).access_token)
  end
end
