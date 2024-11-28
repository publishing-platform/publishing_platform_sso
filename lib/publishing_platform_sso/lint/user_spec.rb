RSpec.shared_examples "a publishing_platform_sso user class" do
  subject { described_class.new(uid: "12345") }

  it "implements #where" do
    expect(described_class).to respond_to(:where)

    result = described_class.where(uid: "123")
    expect(result).to respond_to(:first)
  end

  it "implements #update_attribute" do
    expect(subject).to respond_to(:update_attribute)

    subject.update_attribute(:disabled, true)
    expect(subject).to be_disabled
  end

  it "implements #update!" do
    subject.update!(email: "ab@c.com")
    expect(subject.email).to eq("ab@c.com")
  end

  it "implements #create!" do
    expect(described_class).to respond_to(:create!)
  end

  describe "#has_all_permissions?" do
    it "is false when there are no permissions" do
      subject.update!(permissions: nil)
      required_permissions = %w[signin]
      expect(subject.has_all_permissions?(required_permissions)).to be_falsy
    end

    it "is false when it does not have all required permissions" do
      subject.update!(permissions: %w[signin])
      required_permissions = %w[signin not_granted_permission_one not_granted_permission_two]
      expect(subject.has_all_permissions?(required_permissions)).to be false
    end

    it "is true when it has all required permissions" do
      subject.update!(permissions: %w[signin internal_app])
      required_permissions = %w[signin internal_app]
      expect(subject.has_all_permissions?(required_permissions)).to be true
    end
  end

  specify "the User class and PublishingPlatform::SSO::User mixin work together" do
    auth_hash = {
      "uid" => "12345",
      "info" => {
        "name" => "Joe Smith",
        "email" => "joe.smith@example.com",
      },
      "extra" => {
        "user" => {
          "disabled" => false,
          "permissions" => %w[signin],
          "organisation_slug" => "digital-services",
          "organisation_content_id" => "af07d5a5-df63-4ddc-9383-6a666845ebe9",
        },
      },
    }

    user = described_class.find_for_oauth(auth_hash)
    expect(user).to be_an_instance_of(described_class)
    expect(user.uid).to eq("12345")
    expect(user.name).to eq("Joe Smith")
    expect(user.email).to eq("joe.smith@example.com")
    expect(user).not_to be_disabled
    expect(user.permissions).to eq(%w[signin])
    expect(user.organisation_slug).to eq("digital-services")
    expect(user.organisation_content_id).to eq("af07d5a5-df63-4ddc-9383-6a666845ebe9")
  end
end
