require "spec_helper"
require "publishing_platform_sso/user"
require "publishing_platform_sso/lint/user_spec"

require "ostruct"

RSpec.describe PublishingPlatform::SSO::User do
  before :each do
    @auth_hash = {
      "provider" => "publishing_platform",
      "uid" => "abcde",
      "credentials" => { "token" => "abcdefg", "secret" => "abcdefg" },
      "info" => { "name" => "Joe Smith", "email" => "joe@example.co.uk" },
      "extra" => {
        "user" => {
          "permissions" => [], "organisation_slug" => nil, "organisation_content_id" => nil, "disabled" => false
        },
      },
    }
  end

  it "should extract the user params from the oauth hash" do
    expected = { "uid" => "abcde",
                 "name" => "Joe Smith",
                 "email" => "joe@example.co.uk",
                 "permissions" => [],
                 "organisation_slug" => nil,
                 "organisation_content_id" => nil,
                 "disabled" => false }
    expect(PublishingPlatform::SSO::User.user_params_from_auth_hash(@auth_hash)).to eq(expected)
  end

  context "making sure that the lint spec is valid" do
    let(:described_class) { TestUser }
    it_behaves_like "a publishing_platform_sso user class"
  end
end
