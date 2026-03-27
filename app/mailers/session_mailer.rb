class SessionMailer < ApplicationMailer
  def magic_link(user, token)
    @user = user
    @url = magic_token_session_url(token: token)
    mail subject: "Sign in to Scriptures", to: user.email_address
  end
end
