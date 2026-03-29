class SessionMailer < ApplicationMailer
  def magic_link(user, token, short_code)
    @user = user
    @url = magic_token_session_url(token: token)
    @short_code = short_code
    mail subject: "Sign in to Scriptures", to: user.email_address
  end
end
