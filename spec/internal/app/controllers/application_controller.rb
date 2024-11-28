class ApplicationController < ActionController::Base
  include PublishingPlatform::SSO::ControllerMethods
end
