# frozen_string_literal: true

# Yes, we really do want to turn off the test environment check here.
# Bad things happen if we don't ;-)
ENV["PUBLISHING_PLATFORM_SSO_STRATEGY"] = "real"

require "publishing_platform_sso"
require "capybara/rspec"
require "webmock/rspec"
require "combustion"

Combustion.initialize! :all do
  config.cache_store = :null_store
  config.action_dispatch.show_exceptions = :all
end

require "rspec/rails"
require "capybara/rails"
WebMock.disable_net_connect!

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].sort.each { |f| require f }

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, follow_redirects: false)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.use_transactional_fixtures = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
