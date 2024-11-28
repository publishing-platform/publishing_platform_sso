require "ostruct"

class TestUser < OpenStruct
  include PublishingPlatform::SSO::User

  def self.where(_opts)
    []
  end

  def self.create!(options, _scope = {})
    new(options)
  end

  def update_attribute(key, value)
    send("#{key}=".to_sym, value)
  end

  def update!(options)
    options.each do |key, value|
      update_attribute(key, value)
    end
  end

  def disabled?
    disabled
  end
end
