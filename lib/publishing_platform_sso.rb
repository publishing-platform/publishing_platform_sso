# frozen_string_literal: true

require "rails"

require "publishing_platform_sso/config"
require "publishing_platform_sso/version"
require "publishing_platform_sso/warden_config"
require "omniauth"
require "omniauth/strategies/publishing_platform"

require "publishing_platform_sso/railtie" if defined?(Rails)

module PublishingPlatform
  module SSO
    autoload :FailureApp,               "publishing_platform_sso/failure_app"
    autoload :ControllerMethods,        "publishing_platform_sso/controller_methods"
    autoload :User,                     "publishing_platform_sso/user"
    autoload :ApiAccess,                "publishing_platform_sso/api_access"
    autoload :AuthoriseUser,            "publishing_platform_sso/authorise_user"
    autoload :PermissionDeniedError,    "publishing_platform_sso/errors"

    # User to return as logged in during tests
    mattr_accessor :test_user

    def self.config
      yield PublishingPlatform::SSO::Config
    end

    class Engine < ::Rails::Engine
      # Force routes to be loaded if we are doing any eager load.
      # TODO - check this one - Stolen from Devise because it looked sensible...
      config.before_eager_load(&:reload_routes!)

      OmniAuth.config.allowed_request_methods = %i[post get]

      config.app_middleware.use ::OmniAuth::Builder do
        next if PublishingPlatform::SSO::Config.api_only

        provider :publishing_platform, PublishingPlatform::SSO::Config.oauth_id, PublishingPlatform::SSO::Config.oauth_secret,
                 client_options: {
                   site: PublishingPlatform::SSO::Config.oauth_root_url,
                   authorize_url: "#{PublishingPlatform::SSO::Config.oauth_root_url}/oauth/authorize",
                   token_url: "#{PublishingPlatform::SSO::Config.oauth_root_url}/oauth/access_token",
                   connection_opts: {
                     headers: {
                       user_agent: "publishing_platform_sso/#{PublishingPlatform::SSO::VERSION} (#{ENV['PUBLISHING_PLATFORM_APP_NAME']})",
                     },
                   },
                 }
      end

      def self.default_strategies
        Config.use_mock_strategies? ? %i[mock_publishing_platform_sso publishing_platform_bearer_token] : %i[publishing_platform_sso publishing_platform_bearer_token]
      end

      config.app_middleware.use Warden::Manager do |config|
        config.default_strategies(*default_strategies)
        config.failure_app = PublishingPlatform::SSO::FailureApp
        config.intercept_401 = PublishingPlatform::SSO::Config.intercept_401_responses
      end
    end
  end
end
