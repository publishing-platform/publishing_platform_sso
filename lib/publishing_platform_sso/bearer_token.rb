require "json"
require "oauth2"

module PublishingPlatform
  module SSO
    module BearerToken
      def self.locate(token_string)
        user_details = PublishingPlatform::SSO::Config.cache.fetch(["api-user-cache", token_string], expires_in: 5.minutes) do
          access_token = OAuth2::AccessToken.new(oauth_client, token_string)
          response_body = access_token.get("/user.json?client_id=#{CGI.escape(PublishingPlatform::SSO::Config.oauth_id)}").body
          omniauth_style_response(response_body)
        end

        PublishingPlatform::SSO::Config.user_klass.find_for_oauth(user_details)
      rescue OAuth2::Error
        nil
      end

      def self.oauth_client
        @oauth_client ||= OAuth2::Client.new(
          PublishingPlatform::SSO::Config.oauth_id,
          PublishingPlatform::SSO::Config.oauth_secret,
          site: PublishingPlatform::SSO::Config.oauth_root_url,
          connection_opts: {
            headers: {
              user_agent: "publishing_platform_sso/#{PublishingPlatform::SSO::VERSION} (#{ENV['PUBLISHING_PLATFORM_APP_NAME']})",
            },
          }.merge(PublishingPlatform::SSO::Config.connection_opts),
        )
      end

      # Our User code assumes we're getting our user data back
      # via omniauth and so receiving it in omniauth's preferred
      # structure. Here we're addressing signon directly so
      # we need to transform the response ourselves.
      def self.omniauth_style_response(response_body)
        input = JSON.parse(response_body).fetch("user")

        {
          "uid" => input["uid"],
          "info" => {
            "email" => input["email"],
            "name" => input["name"],
          },
          "extra" => {
            "user" => {
              "permissions" => input["permissions"],
              "organisation_slug" => input["organisation_slug"],
              "organisation_content_id" => input["organisation_content_id"],
            },
          },
        }
      end
    end

    module MockBearerToken
      def self.locate(_token_string)
        dummy_api_user = PublishingPlatform::SSO.test_user || PublishingPlatform::SSO::Config.user_klass.where(email: "dummyapiuser@domain.com").first
        if dummy_api_user.nil?
          dummy_api_user = PublishingPlatform::SSO::Config.user_klass.new
          dummy_api_user.email = "dummyapiuser@domain.com"
          dummy_api_user.uid = rand(10_000).to_s
          dummy_api_user.name = "Dummy API user created by publishing_platform_sso"
        end

        unless dummy_api_user.has_all_permissions?(PublishingPlatform::SSO::Config.permissions_for_dummy_api_user)
          dummy_api_user.permissions = PublishingPlatform::SSO::Config.permissions_for_dummy_api_user
        end

        dummy_api_user.save!
        dummy_api_user
      end
    end
  end
end
