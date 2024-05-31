module PublishingPlatform
  module SSO
    class Railtie < Rails::Railtie
      config.action_dispatch.rescue_responses.merge!(
        "PublishingPlatform::SSO::PermissionDeniedError" => :forbidden,
      )

      initializer "publishing_platform_sso.initializer" do
        PublishingPlatform::SSO.config do |config|
          config.cache = Rails.cache
          config.api_only = Rails.configuration.api_only
        end
        OmniAuth.config.logger = Rails.logger
      end
    end
  end
end
