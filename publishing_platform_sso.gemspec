# frozen_string_literal: true

require_relative "lib/publishing_platform_sso/version"

Gem::Specification.new do |spec|
  spec.name = "publishing_platform_sso"
  spec.version = PublishingPlatform::SSO::VERSION
  spec.authors = ["Publishing Platform"]

  spec.summary = "Client for Publishing Platform's OAuth 2-based SSO."
  spec.description = "Client for Publishing Platform's OAuth 2-based SSO."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir[
    "app/**/*",
    "config/**/*",
    "lib/**/*",
    "README.md",
    "Gemfile",
    "Rakefile"
  ]

  spec.executables = []
  spec.require_paths = %w[lib]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_development_dependency "publishing_platform_rubocop"
end
