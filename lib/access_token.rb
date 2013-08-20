class AccessToken < OAuth2::AccessToken
  attr_reader :token_bearer

  def initialize(token_bearer)
    @token_bearer = token_bearer
    super(oauth_client, token_bearer.token, refresh_token: token_bearer.refresh_token,
                                            expires_at: token_bearer.expires_at)
  end

  def access_token
    if expired?
      new_token = self.refresh!
      token_bearer.token = new_token.token
      token_bearer.refresh_token = new_token.refresh_token
      token_bearer.expires_at = new_token.expires_at
      token_bearer.save!
    end
    new_token || self
  end

  private
  def oauth_client
    @oauth_client ||= OAuth2::Client.new(ENV["STABLE_APP_ID"], ENV["STABLE_APP_SECRET"], site: "https://stable.bignerdranch.com")
  end
end
