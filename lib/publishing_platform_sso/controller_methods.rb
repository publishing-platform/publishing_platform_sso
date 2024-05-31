module PublishingPlatform
  module SSO
    module ControllerMethods
      def self.included(base)
        base.rescue_from PermissionDeniedError do |e|
          if PublishingPlatform::SSO::Config.api_only
            render json: { message: e.message }, status: :forbidden
          else
            render "authorisations/unauthorised", status: :forbidden, locals: { message: e.message }
          end
        end

        unless PublishingPlatform::SSO::Config.api_only
          base.helper_method :user_signed_in?
          base.helper_method :current_user
        end
      end

      def authorise_user!(permissions)
        # Ensure that we're authenticated (and by extension that current_user is set).
        # Otherwise current_user might be nil, and we'd error out
        authenticate_user!

        PublishingPlatform::SSO::AuthoriseUser.call(current_user, permissions)
      end

      def authenticate_user!
        warden.authenticate!
      end

      def user_signed_in?
        warden && warden.authenticated?
      end

      def current_user
        warden.user if user_signed_in?
      end

      def logout
        warden.logout
      end

      def warden
        request.env["warden"]
      end
    end
  end
end
