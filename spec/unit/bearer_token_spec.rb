require "spec_helper"

RSpec.describe PublishingPlatform::SSO::BearerToken do
  describe ".locate" do
    it "creates a new user for a token" do
      response = double(body: {
        user: {
          uid: "asd",
          email: "user@example.com",
          name: "A Name",
          permissions: %w[signin],
          organisation_slug: "digital-services",
          organisation_content_id: "af07d5a5-df63-4ddc-9383-6a666845ebe9",
        },
      }.to_json)

      allow_any_instance_of(OAuth2::AccessToken).to receive(:get).and_return(response)

      created_user = PublishingPlatform::SSO::BearerToken.locate("MY-API-TOKEN")

      expect(created_user.email).to eql("user@example.com")

      same_user_again = PublishingPlatform::SSO::BearerToken.locate("MY-API-TOKEN")

      expect(same_user_again.id).to eql(created_user.id)
    end
  end
end
