class User < ActiveRecord::Base
  include PublishingPlatform::SSO::User

  serialize :permissions, type: Array
end
