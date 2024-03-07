# omniauth-epic-oauth2
Strategy to authenticate with Epic Games via OAuth2 in OmniAuth.

For more details, read the Epic Games documentation on acquiring your Client ID & Client Secret: https://dev.epicgames.com/docs/web-api-ref/authentication

## Installation

Add this line to your application's Gemfile:

```ruby
git 'https://github.com/maxschridde1494/omniauth-epic-oauth2.git', branch: 'main' do
  gem 'omniauth-epic-oauth2'
end
```

And then execute:

    $ bundle install

## Usage

Here's an example for adding the middleware to a Rails app in `config/initializers/omniauth.rb `:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :epic_oauth2, ENV.fetch('EPIC_CLIENT_ID'), ENV.fetch('EPIC_CLIENT_SECRET'), strategy_class: OmniAuth::Strategies::EpicOauth2, scope: 'basic_profile'
end
```

You can now access the OmniAuth Epic OAuth2 URL at `auth/epic_oauth2`

## Auth Hash

Here's an example of an authentication hash available in the callback by accessing `request.env['omniauth.auth']`:

```ruby
{
  "provider"=>"epic",
  "uid"=>"100000000000000000000",
  "info"=>{
    "name" => "John Smith", 
    "accountId"=>"100000000000000000000", 
    "displayName"=>"johnsmith", 
    "linkedAccounts"=>[{"displayName"=>"johnsmith", "identityProviderId"=>"steam"}], 
    "preferredLanguage"=>"en"
  },
  "extra"=>{
    "raw_info"=>{
      "accountId"=>"100000000000000000000", 
      "displayName"=>"johnsmith", 
      "linkedAccounts"=>[{"displayName"=>"johnsmith", "identityProviderId"=>"steam"}], 
      "preferredLanguage"=>"en"
    }
  },                               
  "credentials"=>{
    "token"=> "TOKEN",
    "expires"=>true,
    "expires_at"=>1706146147,
    "refresh_token"=>"REFRESH_TOKEN"
  }
}
```

### Integrate with Devise 

In `config/initializers/devise.rb`

```ruby
Devise.setup do |config|
  ...
  config.omniauth :epic, ENV.fetch('EPIC_CLIENT_ID'), ENV.fetch('EPIC_CLIENT_SECRET'), strategy_class: OmniAuth::Strategies::EpicOauth2, scope: 'basic_profile'
  ...
end
```

NOTE: If you are using this gem with devise with above snippet in `config/initializers/devise.rb` then do not create `config/initializers/omniauth.rb` which will conflict with devise configurations.

Then add the following to `config/routes.rb` so the callback routes are defined.

```ruby
devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
```

Make sure your model is omniauthable. Generally this is `app/models/user.rb`

```ruby
devise :omniauthable, omniauth_providers: [:epic_oauth2]
```

Then make sure your callbacks controller is setup.

```ruby
# app/controllers/users/omniauth_callbacks_controller.rb:

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def epic_oauth2
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Epic'
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.epic_data'] = request.env['omniauth.auth'].except('extra') # Removing extra as it can overflow some session stores
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
  end
end
```

For your views you can login using:

```
<%# omniauth-epic-oauth2 1.0.x uses OmniAuth 2 and requires using HTTP Post to initiate authentication: %>
<%= link_to "Sign in with Epic", user_epic_oauth2_omniauth_authorize_path, method: :post %>

<%# omniauth-epic-oauth2 prior 1.0.0: %>
<%= link_to "Sign in with Epic", user_epic_oauth2_omniauth_authorize_path %>

<%# Devise prior 4.1.0: %>
<%= link_to "Sign in with Epic", user_omniauth_authorize_path(:epic_oauth2) %>
```

An overview is available at https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/maxschridde1494/omniauth-epic-oauth2.git.


