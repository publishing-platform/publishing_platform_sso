require "spec_helper"

RSpec.describe PublishingPlatform::SSO::MockBearerToken do
  it "updates the permissions of the user" do
    # setup - ensure extra mock permissions required are nil and
    # call .locate to create the dummy user initially
    PublishingPlatform::SSO::Config.additional_mock_permissions_required = nil
    dummy_user = subject.locate("ABC")
    expect(dummy_user.permissions).to match_array(%w[signin])

    # add an extra permission
    PublishingPlatform::SSO::Config.additional_mock_permissions_required = "extra_permission"

    # ensure the dummy user is returned
    expect(PublishingPlatform::SSO).to receive(:test_user).and_return(dummy_user)

    # call .locate again...this should update our permissions
    dummy_user_two = subject.locate("ABC")
    expect(dummy_user_two.permissions).to match_array(%w[signin extra_permission])
  end
end
