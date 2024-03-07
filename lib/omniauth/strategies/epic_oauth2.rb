require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class EpicOauth2 < OmniAuth::Strategies::OAuth2
      option :name, 'epic'

      option :client_options, {
        site: 'https://api.epicgames.dev',
        authorize_url: 'https://www.epicgames.com/id/authorize',
        token_url: '/epic/oauth/v2/token'
      }

      option :authorize_options, %i[redirect_uri scope state]

      def callback_url
        options[:redirect_uri] || (full_host + callback_path)
      end

      uid { raw_info['accountId'] }

      info do
        raw_info.merge({
                         name: raw_info['displayName']
                       })
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get(
          'https://api.epicgames.dev/epic/id/v2/accounts',
          { params: { accountId: access_token['account_id'] } }
        ).parsed[0]
      end
    end
  end
end
