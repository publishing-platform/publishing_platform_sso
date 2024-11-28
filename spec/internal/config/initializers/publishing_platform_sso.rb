PublishingPlatform::SSO.config do |config|
  config.user_model   = "User"
  config.oauth_id     = "publishing-platform-sso-test"
  config.oauth_secret = "secret"
  config.oauth_root_url = "http://signon"
end
