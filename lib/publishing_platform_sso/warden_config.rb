require "warden"
require "warden-oauth2"
require "publishing_platform_sso/bearer_token"

def logger
  Rails.logger || env["rack.logger"]
end

Warden::Manager.serialize_into_session do |user|
  if user.respond_to?(:uid) && user.uid
    [user.uid, Time.now.utc.iso8601]
  end
end

Warden::Manager.serialize_from_session do |(uid, auth_timestamp)|
  # This will reject old sessions that don't have a previous login timestamp
  if auth_timestamp.is_a?(String)
    begin
      auth_timestamp = Time.parse(auth_timestamp)
    rescue ArgumentError
      auth_timestamp = nil
    end
  end

  if auth_timestamp && ((auth_timestamp + PublishingPlatform::SSO::Config.auth_valid_for) > Time.now.utc)
    PublishingPlatform::SSO::Config.user_klass.where(uid:).first
  end
end

Warden::Strategies.add(:publishing_platform_sso) do
  def valid?
    !::PublishingPlatform::SSO::ApiAccess.api_call?(env)
  end

  def authenticate!
    logger.debug("Authenticating with publishing_platform_sso strategy")

    if request.env["omniauth.auth"].nil?
      fail!("No credentials, bub")
    else
      user = prep_user(request.env["omniauth.auth"])
      success!(user)
    end
  end

private

  def prep_user(auth_hash)
    user = PublishingPlatform::SSO::Config.user_klass.find_for_oauth(auth_hash)
    fail!("Couldn't process credentials") unless user
    user
  end
end

Warden::OAuth2.configure do |config|
  config.token_model = PublishingPlatform::SSO::Config.use_mock_strategies? ? PublishingPlatform::SSO::MockBearerToken : PublishingPlatform::SSO::BearerToken
end
Warden::Strategies.add(:publishing_platform_bearer_token, Warden::OAuth2::Strategies::Bearer)

Warden::Strategies.add(:mock_publishing_platform_sso) do
  def valid?
    !::PublishingPlatform::SSO::ApiAccess.api_call?(env)
  end

  def authenticate!
    logger.warn("Authenticating with mock_publishing_platform_sso strategy")

    test_user = PublishingPlatform::SSO.test_user
    test_user ||= ENV["PUBLISHING_PLATFORM_SSO_MOCK_INVALID"].present? ? nil : PublishingPlatform::SSO::Config.user_klass.first
    if test_user
      # Brute force ensure test user has correct perms to signin
      unless test_user.has_permission?("signin")
        permissions = test_user.permissions || []
        test_user.update_attribute(:permissions, permissions << "signin")
      end
      success!(test_user)
    elsif Rails.env.test? && ENV["PUBLISHING_PLATFORM_SSO_MOCK_INVALID"].present?
      fail!(:invalid)
    else
      raise "publishing_platform_sso running in mock mode and no test user found. Normally we'd load the first user in the database. Create a user in the database."
    end
  end
end
