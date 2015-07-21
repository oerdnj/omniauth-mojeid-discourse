# name: omniauth-mojeid-discourse
# about: Authenticate with discourse with mojeID
# version: 0.1.0
# author: parasquid
# modified for mojeID by: oerdnj

gem 'omniauth-mojeid'

class mojeIDAuthenticator < ::Auth::Authenticator

  CLIENT_ID = ''
  CLIENT_SECRET = ''

  def name
    'mojeid'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    # grap the info we need from omni auth
    data = auth_token[:info]
    name = data["first_name"]
    mojeID_uid = auth_token["uid"]
    email = data['email']

    # plugin specific data storage
    current_info = ::PluginStore.get("mojeID", "mojeID_uid_#{mojeID_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = name
    result.extra_data = { mojeID_uid: mojeID_uid }
    result.email = email

    result
  end

  def after_create_account(user, auth)
    data = auth[:extra_data]
    ::PluginStore.set("mojeID", "mojeID_uid_#{data[:mojeID_uid]}", {user_id: user.id })
  end

  def register_middleware(omniauth)
    omniauth.provider :mojeid,
     CLIENT_ID,
     CLIENT_SECRET
  end
end


auth_provider :title => 'with mojeID Account',
    :message => 'Log in via mojeID Account (Make sure pop up blockers are not enabled).',
    :frame_width => 920,
    :frame_height => 800,
    :authenticator => mojeIDAuthenticator.new


# We ship with zocial, it may have an icon you like http://zocial.smcllns.com/sample.html
#  in our current case we have an icon for vk
register_css <<CSS

.btn-social.mojeID {
  background: #46698f;
}

.btn-social.mojeID:before {
  content: "N";
}

CSS
