class User < ActiveRecord::Base
  before_create :generate_api_token

  has_one :oauth_token

  private

  def generate_api_token
    self.api_token = SecureRandom.uuid
  end
end
