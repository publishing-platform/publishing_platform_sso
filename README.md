# publishing_platform_sso

This gem provides everything needed to integrate an application with [Signon](https://github.com/publishing-platform/signon). It's a wrapper around [OmniAuth](https://github.com/intridea/omniauth) that adds a 'strategy' for oAuth2 integration against Signon,
and the necessary controller to support that request flow.


## Usage

### Integration with a Rails 4+ app

- Include the gem in your Gemfile:

  ```ruby
  gem 'publishing_platform_sso'
  ```

- Create a "users" table in the database.  Example migration:

  ```ruby
  class CreateUsers < ActiveRecord::Migration[7.1]
    def change
      create_table :users do |t|
      t.string  :name
      t.string  :email
      t.string  :uid
      t.string  :organisation_slug
      t.string  :organisation_content_id
      t.string  :app_name # api only
      t.text    :permissions      
      t.boolean :disabled, default: false
      
      t.timestamps
      end
    end
  end
  ```

- Create a User model with the following:

  ```ruby
  serialize :permissions, Array
  ```

- Add to your `ApplicationController`:

  ```ruby
  include PublishingPlatform::SSO::ControllerMethods
  before_action :authenticate_user!
  ```

### Securing your application

[PublishingPlatform::SSO::ControllerMethods](/lib/publishing_platform_sso/controller_methods.rb) provides some useful methods for your application controllers.

To make sure that only people with a signon account and permission to use your app are allowed in use `authenticate_user!`.

```ruby
class ApplicationController < ActionController::Base
  include PublishingPlatform::SSO::ControllerMethods
  before_action :authenticate_user!
  # ...
end
```

You can refine authorisation to specific controller actions based on permissions using `authorise_user!`. All permissions are assigned via Signon.

```ruby
class PublicationsController < ActionController::Base
  include PublishingPlatform::SSO::ControllerMethods
  before_action :authorise_for_editing!, except: [:show, :index]
  # ...
private
  def authorise_for_editing!
    authorise_user!('edit_publications')
  end
end
```

`authorise_user!` can be configured to check for multiple permissions:

```ruby
# fails unless the user has at least one of these permissions
authorise_user!(any_of: %w(edit create))

# fails unless the user has both of these permissions
authorise_user!(all_of: %w(edit create))
```

The signon application makes sure that only users who have been granted access to the application can access it (e.g. they have the `signin` permission for your app).

### Authorisation for API Users

In addition to the single-sign-on strategy, this gem also allows authorisation
via a "bearer token". This is used by publishing applications to be authorised
as an API user.

To authorise with a bearer token, a request has to be made with the header:

```
Authorization: Bearer your-token-here
```

To avoid making these requests for each incoming request, this gem will [automatically cache a successful response](/lib/publishing_platform_sso/bearer_token.rb), using the [Rails cache](/lib/publishing_platform_sso/railtie.rb).

If you are using a Rails app in
[api_only](http://guides.rubyonrails.org/api_app.html) mode this gem will
automatically disable the oauth layers which use session persistence. You can
configure this gem to be in api_only mode (or not) with:

```ruby
PublishingPlatform::SSO.config do |config|
  # ...
  # Only support bearer token authentication and send responses in JSON
  config.api_only = true
end
```

### Use in production mode

To use publishing_platform_sso in production you will need to setup the following environment variables, which we look for in [the config](/lib/publishing_platform_sso/config.rb). You will need to have admin access to Signon to get these.

- PUBLISHING_PLATFORM_SSO_OAUTH_ID
- PUBLISHING_PLATFORM_SSO_OAUTH_SECRET

### Use in development mode

In development, you generally want to be able to run an application without needing to run your own SSO server as well. publishing_platform_sso facilitates this by using a 'mock' mode in development. Mock mode loads an arbitrary user from the local application's user tables:

```ruby
PublishingPlatform::SSO.test_user || PublishingPlatform::SSO::Config.user_klass.first
```

To make it use a real strategy (e.g. if you're testing an app against the signon server), set the following environment variable when you run your app:

```
PUBLISHING_PLATFORM_SSO_STRATEGY=real
```

### Extra permissions for api users

By default the mock strategies will create a user with `signin` permission.

If your application needs different or extra permissions for access, you can specify this by adding the following to your config:

```ruby
PublishingPlatform::SSO.config do |config|
  # other config here
  config.additional_mock_permissions_required = ["array", "of", "permissions"]
end
```

The mock bearer token will then ensure that the dummy api user has the required permission.

### Testing in your application

If your app is using `rspec`, there is a [shared examples spec](/lib/publishing_platform_sso/lint/user_spec.rb) compatible with `PublishingPlatform::SSO::User`:

```ruby
require 'publishing_platform_sso/lint/user_spec'

describe User do
  it_behaves_like "a publishing_platform_sso user class"
end

### Running the test suite

Run the tests with:

```
bundle exec rake
```

## Licence

[MIT License](LICENSE)