# frozen_string_literal: true

require_relative "lib/publishing_platform_sso/version"

Gem::Specification.new do |spec|
  spec.name = "publishing_platform_sso"
  spec.version = PublishingPlatform::SSO::VERSION
  spec.authors = ["Publishing Platform"]

  spec.summary = "Client for Publishing Platform's OAuth 2-based SSO."
  spec.description = "Client for Publishing Platform's OAuth 2-based SSO."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir[
    "app/**/*",
    "config/**/*",
    "lib/**/*",
    "README.md",
    "Gemfile",
    "Rakefile",
  ]

  spec.executables = []
  spec.require_paths = %w[lib]

  spec.add_dependency "publishing_platform_location", "~> 0.3"

  spec.add_dependency "oauth2", "~> 2.0"
  spec.add_dependency "omniauth", "~> 2.1"
  spec.add_dependency "omniauth-oauth2", "~> 1.8"
  spec.add_dependency "rails", ">= 7"
  spec.add_dependency "warden", "~> 1.2"
  spec.add_dependency "warden-oauth2", "~> 0.0.1"

  spec.add_development_dependency "capybara", "~> 3"
  spec.add_development_dependency "combustion", "~> 1.3"
  spec.add_development_dependency "publishing_platform_rubocop", "~> 0.2"
  spec.add_development_dependency "rspec-rails", "~> 8"
  spec.add_development_dependency "sqlite3", "~> 2.1"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "webmock", "~> 3.24"
end
