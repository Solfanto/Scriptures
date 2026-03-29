class SessionMailer < ApplicationMailer
  def magic_link(user, token, short_code)
    @user = user
    @url = session_magic_token_url(token: token)
    @short_code = short_code
    mail subject: "Sign in to Scriptures", to: user.email
  end
end
