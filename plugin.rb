# name: omniauth-mojeid-discourse
# about: Authenticate with discourse with mojeID
# version: 0.1.0
# author: parasquid
# modified for mojeID by: oerdnj

gem 'omniauth-mojeid'

class mojeIDAuthenticator < ::Auth::OAuth2Authenticator

  CLIENT_ID = ''
  CLIENT_SECRET = ''

  def name
    'mojeid'
  end

  def register_middleware(omniauth)
    omniauth.provider :mojeid,
     CLIENT_ID,
     CLIENT_SECRET
  end
end

class OmniAuth::Strategies::mojeID < OmniAuth::Strategies::OAuth2
  # Give your strategy a name.
  option :name, "mojeid"

  # This is where you pass the options you would pass when
  # initializing your consumer from the OAuth gem.
  option :client_options, site: 'https://mojeid.fred.nic.cz/'

  # These are called after authentication has succeeded. If
  # possible, you should try to set the UID without making
  # additional calls (if the user id is returned with the token
  # or as a URI parameter). This may not be possible with all
  # providers.
  uid { raw_info['id'].to_s }

  info do
    {
      :name => raw_info['name'],
      :email => raw_info['email']
    }
  end

  extra do
    {
      'raw_info' => raw_info
    }
  end

  def raw_info
    @raw_info ||= access_token.get('/oidc/token/').parsed
  end
end

auth_provider :title => 'with mojeID Account',
    :message => 'Log in via mojeID Account (Make sure pop up blockers are not enabled).',
    :frame_width => 920,
    :frame_height => 800,
    :authenticator => mojeIDAuthenticator.new('mojeid', trusted: true, auto_create_account: true)
