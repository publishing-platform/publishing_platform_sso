Rails.application.routes.draw do
  next if PublishingPlatform::SSO::Config.api_only

  get "/auth/publishing_platform/callback", to: "authentications#callback", as: :publishing_platform_sign_in
  get "/auth/publishing_platform/sign_out", to: "authentications#sign_out", as: :publishing_platform_sign_out
  get "/auth/failure",                      to: "authentications#failure",  as: :auth_failure
end
